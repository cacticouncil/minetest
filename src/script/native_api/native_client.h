#pragma once
#include <string>
#include <tuple>
#include <map>
#include <list>
#include "client/client.h"
#include "script/cpp_api/s_base.h"
#include "nodedef.h"
#include "util/areastore.h"

class NativeModApiClient
{
private:
	static std::string native_get_current_modname(std::string current_mod);
	static std::string native_get_last_run_mod(
			std::string current_mod, ScriptApiBase *scriptApiBase);
	static int native_set_last_run_mod(const char *mod, ScriptApiBase *scriptApiBase);
	static int native_print(std::string text);
	static int NativeModApiClient::native_display_chat_message(
			std::string message, Client *client);
	static int native_send_chat_message(std::string message, Client *client);
	static int native_clear_out_chat_queue(Client *client);
	static std::list<const char *> native_get_player_names(Client *client);
	static bool native_show_formspec(
			std::string *formname, std::string *formspec, Client *client);
	static int native_send_respawn(Client *client);
	static bool native_disconnect(Client *client);
	static std::string native_gettext(std::string text);
	static const NodeDefManager *native_get_node_or_nil(v3s16 pos, Client *client);
	static char *native_get_language();
	static ItemStack *native_get_wielded_item(Client *client);
	static NodeMetadata *native_get_meta(v3s16 p, Client *client);
	static s32 native_sound_play(Client *client, SimpleSoundSpec spec, v3f default,
		float gain = 1.0f, float pitch = 1.0f, float looped = false, v3f *pos = nullptr);
	static int native_sound_stop(u32 handle, Client *client);
	static std::tuple<Address, std::string, std::string, int, int>
	native_get_server_info();
	static const ItemDefinition *native_get_item_def(
			Client *client, IGameDef *gdef, std::string name);
	static const ContentFeatures *native_get_node_def(
			Client *client, IGameDef *gdef, std::string name);
	static std::map<std::string, bool> native_get_privilege_list();
	static std::string native_get_builtin_path();
};
