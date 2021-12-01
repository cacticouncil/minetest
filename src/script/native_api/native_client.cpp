#include "native_client.h"
#include "chatmessage.h"
#include "client/client.h"
#include "client/clientevent.h"
#include "client/sound.h"
#include "client/clientenvironment.h"
#include "common/c_content.h"
#include "common/c_converter.h"
#include "cpp_api/s_base.h"
#include "gettext.h"
#include "lua_api/l_item.h"
#include "lua_api/l_nodemeta.h"
#include "gui/mainmenumanager.h"
#include "map.h"
#include "util/string.h"
#include "nodedef.h"

std::string NativeModApiClient::native_get_current_modname(std::string current_mod)
{
	return current_mod;
}

std::string NativeModApiClient::native_get_last_run_mod(
		std::string current_mod, ScriptApiBase *scriptApiBase)
{
	if (current_mod.empty()) {
		return scriptApiBase->getOrigin().c_str();
	}
	return current_mod;
}

int NativeModApiClient::native_set_last_run_mod(
		const char *mod, ScriptApiBase *scriptApiBase)
{
	scriptApiBase->setOriginDirect(mod);
	return true;
}

int NativeModApiClient::native_print(std::string text)
{
	rawstream << text << std::endl;
	return 0;
}

int NativeModApiClient::native_display_chat_message(std::string message, Client *client)
{
	client->pushToChatQueue(new ChatMessage(utf8_to_wide(message)));
	return true;
}

int NativeModApiClient::native_send_chat_message(std::string message, Client *client)
{
	// If server disabled this API, discard

	//clang-format off
	if (client->checkCSMRestrictionFlag(CSMRestrictionFlags::CSM_RF_CHAT_MESSAGES))
		return 0;
	//clang-format on

	client->sendChatMessage(utf8_to_wide(message));
	return 0;
}

int NativeModApiClient::native_clear_out_chat_queue(Client *client)
{
	client->clearOutChatQueue();
	return 0;
}

std::list<const char *> NativeModApiClient::native_get_player_names(Client *client)
{
	std::list<const char *> returnList;

	//clang-format off
	if (client->checkCSMRestrictionFlag(
			    CSMRestrictionFlags::CSM_RF_READ_PLAYERINFO)) {
		return returnList;
	}
	//clang-format on

	const std::list<std::string> &plist = client->getConnectedPlayerNames();
	std::list<std::string>::const_iterator iter;
	for (iter = plist.begin(); iter != plist.end(); ++iter) {
		returnList.push_back((*iter).c_str());
	}
	return returnList;
}

bool NativeModApiClient::native_show_formspec(
		std::string *formname, std::string *formspec, Client *client)
{
	ClientEvent *event = new ClientEvent();
	event->type = CE_SHOW_LOCAL_FORMSPEC;
	event->show_formspec.formname = formname;
	event->show_formspec.formspec = formspec;
	client->pushToEventQueue(event);
	return true;
}

int NativeModApiClient::native_send_respawn(Client *client)
{
	client->sendRespawn();
	return 0;
}

bool NativeModApiClient::native_disconnect(Client *client)
{
	if (client->isShutdown()) {
		return false;
	}

	g_gamecallback->disconnect();
	return true;
}

std::string NativeModApiClient::native_gettext(std::string text)
{
	return text;
}

const NodeDefManager *NativeModApiClient::native_get_node_or_nil(
		v3s16 pos, Client *client)
{
	bool pos_ok;
	MapNode n = client->getNode(pos, &pos_ok);
	if (pos_ok) {
		return client->ndef();
	} else {
		return nullptr;
	}
}

char *NativeModApiClient::native_get_language()
{
	char *locale = setlocale(LC_ALL, "");
	return locale;
}

ItemStack *NativeModApiClient::native_get_wielded_item(Client *client)
{
	LocalPlayer *player = client->getEnv().getLocalPlayer();
	if (!player)
		return nullptr;

	ItemStack selected_item;
	player->getWieldedItem(&selected_item, nullptr);
	return &selected_item;
}

NodeMetadata *NativeModApiClient::native_get_meta(v3s16 p, Client *client)
{
	NodeMetadata *meta = client->getEnv().getMap().getNodeMetadata(p);
	return meta;
}

s32 NativeModApiClient::native_sound_play(Client *client, SimpleSoundSpec spec, v3f default,
				  float gain, float pitch, float looped, v3f *pos)
{
	ISoundManager *sound = client->getSoundManager();

	s32 handle;

	if (pos == nullptr) {
		*pos = default * BS;
		handle = sound->playSoundAt(
				spec.name, looped, gain * spec.gain, *pos, pitch);
		return handle;
	}

	return sound->playSound(spec.name, looped, gain * spec.gain, 0.0f, pitch);
}

int NativeModApiClient::native_sound_stop(u32 handle, Client *client)
{
	client->getSoundManager()->stopSound(handle);
	return 0;
}

std::tuple<Address, std::string, std::string, int, int>
NativeModApiClient::native_get_server_info()
{
	Client *client = client;
	Address serverAddress = client->getServerAddress();
	std::string address = client->getAddressName().c_str();
	std::string ip = serverAddress.serializeString().c_str();
	int port = serverAddress.getPort();
	int protocol_version = client->getProtoVersion();

	return std::tuple<Address, std::string, std::string, int, int>(
			serverAddress, address, ip, port, protocol_version);
}

const ItemDefinition *NativeModApiClient::native_get_item_def(
		Client *client, IGameDef *gdef, std::string name)
{
	assert(gdef);

	IItemDefManager *idef = gdef->idef();
	assert(idef);

	//clang-format off
	if (client->checkCSMRestrictionFlag(CSMRestrictionFlags::CSM_RF_READ_ITEMDEFS))
		return nullptr;
	//clang-format on

	if (!idef->isKnown(name))
		return nullptr;
	const ItemDefinition &def = idef->get(name);

	return &def;
}

const ContentFeatures *NativeModApiClient::native_get_node_def(
		Client *client, IGameDef *gdef, std::string name)
{
	assert(gdef);

	const NodeDefManager *ndef = gdef->ndef();
	assert(ndef);

	//clang-format off
	if (client->checkCSMRestrictionFlag(CSMRestrictionFlags::CSM_RF_READ_NODEDEFS))
		return 0;
	//clang-format on

	const ContentFeatures &cf = ndef->get(ndef->getId(name));
	if (cf.name != name)
		return nullptr;

	return &cf;
}

std::map<std::string, bool> NativeModApiClient::native_get_privilege_list()
{
	const Client *client = client;

	std::map<std::string, bool> result;
	for (const std::string &priv : client->getPrivilegeList()) {
		result.insert(std::pair<std::string, bool>(priv.c_str(), true));
	}
	return result;
}

std::string NativeModApiClient::native_get_builtin_path()
{
	std::string val = BUILTIN_MOD_NAME ":";
	return val;
}