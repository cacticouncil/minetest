#include <string>
#include <vector>

class WasmInjector {
    private:
        WasmInjector() {}
        static std::string get_wasm_bytes(const char* path);
        static std::vector<std::string> get_js_contents(const char* path);
        static bool write_js(std::vector<std::string> js, const char *path);
	    static std::string get_containing_directory(const char *path);
	    static void compile_mod(const char *path);
    public:
	    static bool file_exists(const std::string &name);
        static bool inject_wasm(const char *path);
};
