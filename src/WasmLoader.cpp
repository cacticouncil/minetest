/*
 * new class that holds all the code that spins up spidermonkey and runs js/wasm
*/

#include <iostream>
#include <string>
#include <vector>

#include "jsapi.h"
#include "js/Initialization.h"
#include "js/CompilationAndEvaluation.h"
#include "js/SourceText.h"
#include "js/Utility.h"
#include "js/CompileOptions.h"

#include "WasmInjector.h"
#include "WasmLoader.h"

static JSClassOps global_ops = { nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
		nullptr, nullptr, nullptr, nullptr, JS_GlobalObjectTraceHook };
/* The class of the global object. */
static JSClass global_class = { "global", JSCLASS_GLOBAL_FLAGS, &global_ops };


// # Params:
// ## cx: 
std::string WasmLoader::getModProperty(JSContext *cx, JSObject *source, const char *prop)
{
	// Creates a Handle from the raw location `source`
	JS::HandleObject object = JS::HandleObject::fromMarkedLocation(&source);

	JS::Value v;
	JS::MutableHandleValue prop_value =
		JS::MutableHandleValue::fromMarkedLocation(&v);

	JS_GetProperty(cx, object, prop, prop_value);

	JSString *str = prop_value.toString();
	size_t size = JS_GetStringLength(str);
	char *buffer = (char *)malloc(size);
	JS_EncodeStringToBuffer(cx, str, buffer, size);

	std::string res = "";
	for (int i = 0; i < size; i++) {
		res += buffer[i];
	}
	free(buffer);

	return res;
}

std::vector<std::string> WasmLoader::loadWasmData(const std::string &path)
{
	// Initialize the JS engine and context
	if (!JS_IsInitialized())
		JS_Init();											// Starts Spidermonkey
	std::vector<std::string> ret_vec;					// Vector containing Strings of mod info
	JSContext *cx = JS_NewContext(8L * 1024 * 1024);	// Using the default max heap size and passing nullptr for rt
	
	// Check if context is valid
	if (!cx)
		return ret_vec;

	// Attempt to initialize the runtime's self hosted code. Needed before JS_NewGlobalObject
	if (!JS::InitSelfHostedCode(cx))
		return ret_vec;

	// Limit Scope to the Realm
	{
		JS::RealmOptions options;
		JS::RootedObject global(cx, JS_NewGlobalObject(cx, &global_class, nullptr, JS::FireOnNewGlobalHook, options));
		if (!global)
			return ret_vec;

		JS::RootedValue rval(cx); // Root the context?
		{
			JSAutoRealm ar(cx, global);
			if (!JS::InitRealmStandardClasses(cx))
				return ret_vec;

			const char *filename = "noname";
			int lineno = 1;
			JS::CompileOptions opts(cx);
			opts.setFileAndLine(filename, lineno);

			WasmInjector::inject_wasm(path.c_str());
			std::string js_path = path + "\\mod.js";

			bool ok = JS::EvaluateUtf8Path(cx, opts, js_path.c_str(), &rval);
			if (!ok)
				return ret_vec;

			if (rval.isObject()) {
				JSObject *res = rval.toObjectOrNull();

				ret_vec.push_back(WasmLoader::getModProperty(cx, res, "name"));
				ret_vec.push_back(WasmLoader::getModProperty(cx, res, "description"));
				ret_vec.push_back(WasmLoader::getModProperty(cx, res, "texture"));
				ret_vec.push_back(WasmLoader::getModProperty(cx, res, "material"));
			}
		}
	}
	JS_DestroyContext(cx);
	// We don't shutdown JS here, we do it in clientlauncher.cpp, where the game loop exits.
	// This way, spidermonkey isn't reinitialized and one can re-enter mods.
	return ret_vec;
}
