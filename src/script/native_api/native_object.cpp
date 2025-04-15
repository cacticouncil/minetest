#include "native_object.h"

void NativeObjectRef::n_remove(ServerActiveObject *sao)
{
	if (sao == nullptr || sao->getType() == ACTIVEOBJECT_TYPE_PLAYER)
		return;
	else
	{
		sao->clearChildAttachments();
		sao->clearParentAttachment();

		verbosestream << "ObjectRef::l_remove(): id=" << sao->getId()
			      << std::endl;
		sao->markForRemoval();
	}
}

std::unique_ptr<v3f> NativeObjectRef::n_get_pos(const ServerActiveObject *sao)
{
	std::unique_ptr<v3f> pos;
	if (sao != nullptr)
		pos = std::make_unique<v3f>(sao->getBasePosition());
	
	return pos;
}

void NativeObjectRef::n_set_pos(ServerActiveObject* sao, const v3f& pos)
{
	if (sao != nullptr)
		sao->setPos(pos);
}

void NativeObjectRef::n_move_to(ServerActiveObject* sao, const v3f& pos, const bool continuous)
{
	if (sao != nullptr)
		sao->moveTo(pos, continuous);
}

//will theoretically return nullptr if either puncher or punchee doesn't exist.
std::unique_ptr<u16> NativeObjectRef::n_punch(Server *server, ServerActiveObject *puncher,
		ServerActiveObject *punchee, const ToolCapabilities &tc, const v3f &dir,
		const float time_from_last_punch)
{
	std::unique_ptr<u16> wear;
	if (puncher != nullptr && punchee != nullptr)
	{
		u16 puncher_og_hp = puncher->getHP();
		u16 punchee_og_hp = punchee->getHP();
		wear = std::make_unique<u16>(punchee->punch(dir, &tc, puncher, time_from_last_punch));

		if (puncher_og_hp != punchee->getHP() &&
				punchee->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
			server->SendPlayerHPOrDie((PlayerSAO *)punchee,
					PlayerHPChangeReason(PlayerHPChangeReason::
									     PLAYER_PUNCH,
							puncher));
		}

		if (punchee_og_hp != puncher->getHP() &&
				puncher->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
			server->SendPlayerHPOrDie((PlayerSAO *)puncher,
					PlayerHPChangeReason(PlayerHPChangeReason::
									     PLAYER_PUNCH,
							punchee));
		}
	}
	return wear;
}
void NativeObjectRef::n_right_click(ServerActiveObject* clicker, ServerActiveObject* clickee)
{
	if (clicker != nullptr && clickee != nullptr)
		clicker->rightClick(clickee);
}

void NativeObjectRef::n_set_hp(Server *server, ServerActiveObject *sao, const int hp)
{
	PlayerHPChangeReason reason(PlayerHPChangeReason::SET_HP);
	sao->setHP(hp, reason);

	if (sao->getType() == ACTIVEOBJECT_TYPE_PLAYER)
		server->SendPlayerHPOrDie((PlayerSAO *)sao, reason);
}

int NativeObjectRef::n_get_hp(ServerActiveObject *sao)
{
	if (sao != nullptr)
		return sao->getHP();
	return 1;
}

InventoryLocation NativeObjectRef::n_get_inventory(ServerActiveObject *sao)
{
	return sao->getInventoryLocation();
}

std::unique_ptr<std::string> NativeObjectRef::n_get_wield_list(const ServerActiveObject* sao)
{
	std::unique_ptr<std::string> wield_list;
	if (sao != nullptr)
		wield_list = std::make_unique<std::string>(sao->getWieldList());
	return wield_list;
}

int NativeObjectRef::n_get_wield_index(const ServerActiveObject *sao)
{
	if (sao != nullptr)
		return sao->getWieldIndex();
	return -1;
}

bool NativeObjectRef::n_set_wielded_item(Server* server,ServerActiveObject *sao, ItemStack &item)
{
	bool success = sao->setWieldedItem(item);
	if (success && sao->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
		server->SendInventory((PlayerSAO *)sao, true);
	}
	return success;
}

bool NativeObjectRef::n_set_armor_groups(ServerActiveObject *sao, ItemGroupList &groups)
{
	if (sao == nullptr)
		return false;
	if (sao->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
		if (!g_settings->getBool("enable_damage") &&
				!itemgroup_get(groups, "immortal")) {
			warningstream << "Mod tried to enable damage for a player, but "
					 "it's "
					 "disabled globally. Ignoring."
				      << std::endl;
			groups["immortal"] = 1;
		}
	}
	sao->setArmorGroups(groups);
	return true;
}

std::unique_ptr<ItemGroupList> NativeObjectRef::n_get_armor_groups(const ServerActiveObject *sao)
{
	std::unique_ptr<ItemGroupList> armor_groups;
	if (sao != nullptr)
		armor_groups = std::make_unique<ItemGroupList>(sao->getArmorGroups());
	return armor_groups;
}

void NativeObjectRef::n_set_animation(ServerActiveObject* sao, const v2f frame_range,
	const float frame_speed, const float frame_blend, const bool frame_loop)
{
	if (sao != nullptr)
	{
		sao->setAnimation(frame_range, frame_speed, frame_blend, frame_loop);
	}
}

int NativeObjectRef::n_get_animation(ServerActiveObject *sao, v2f &frames, float &frame_speed, float &frame_blend, bool &frame_loop)
{
	if (sao == nullptr)
		return 0;
	else
	{
		sao->getAnimation(&frames, &frame_speed, &frame_blend, &frame_loop);
		return 4;
	}
}

bool NativeObjectRef::n_set_local_animation(Server* server, RemotePlayer* player, v2s32 frames[], const f32 frame_speed)
{
	if (!player)
		return false;
	else
	{
		server->setLocalPlayerAnimations(player, frames, frame_speed);
		return true;
	}
}

int NativeObjectRef::n_get_local_animation(RemotePlayer* player, v2s32* frames, float& frame_speed)
{
	if (player)
	{
		player->getLocalAnimations(frames, &frame_speed);
		return 5;
	}
	return 0;
}

int NativeObjectRef::n_set_eye_offset(Server* server, RemotePlayer* player, const v3f& offset_first, const v3f& offset_third)
{
	if (player && server)
	{
		server->setPlayerEyeOffset(player, offset_first, offset_third);
		return 1;
	}
	return 0;
}

v3f* NativeObjectRef::n_get_eye_offset(RemotePlayer* player)
{
	if (player)
	{
		v3f *eye_offsets = new v3f[2];
		eye_offsets[0] = player->eye_offset_first;
		eye_offsets[1] = player->eye_offset_third;
		return eye_offsets;
	}
	return nullptr;
}

bool NativeObjectRef::n_send_mapblock(Server* server, const session_t& peerId, const v3s16& pos)
{
	return server->SendBlock(peerId, pos);
}

void NativeObjectRef::n_set_animation_frame_speed(ServerActiveObject* sao, const float& frame_speed)
{
	sao->setAnimationSpeed(frame_speed);
}

void NativeObjectRef::n_set_bone_position(ServerActiveObject* sao,
		const std::string &bone, const v3f &position, const v3f &rotation)
{
	if (sao != nullptr)
	{
		sao->setBonePosition(bone, position, rotation);
	}
}

void NativeObjectRef::n_get_bone_position(ServerActiveObject *sao, const std::string& bone,
		v3f &position, v3f &rotation)
{
	sao->getBonePosition(bone, &position, &rotation);
}

void NativeObjectRef::n_set_attach(ServerActiveObject *parent,
		ServerActiveObject *attachment, const std::string &bone,
		const v3f &position, const v3f &rotation, const bool &force_visible)
{
	attachment->setAttachment(parent->getId(), bone, position, rotation, force_visible);
	parent->addAttachmentChild(attachment->getId());
}
int NativeObjectRef::n_get_attach(ServerActiveObject* sao, int& parent_id, std::string& bone, v3f& position,
	v3f& rotation, bool& force_visible)
{
	if (sao && parent_id != 0)
	{
		sao->getAttachment(&parent_id, &bone, &position, &rotation, &force_visible);
		return 5;
	}
	return 0;
}

std::unique_ptr<std::unordered_set<int>> NativeObjectRef::n_get_children(ServerActiveObject *sao)
{
	std::unique_ptr<std::unordered_set<int>> children;
	if (sao)
	{
		children = std::make_unique<std::unordered_set<int>>(sao->getAttachmentChildIds());
	}
	return children;
}

void NativeObjectRef::n_set_detach(ServerActiveObject* sao)
{
	if (sao)
		sao->clearParentAttachment();
}

void NativeObjectRef::n_set_properties(ServerActiveObject* sao)
{
	if (sao)
		sao->notifyObjectPropertiesModified();
}

ObjectProperties* NativeObjectRef::n_get_properties(ServerActiveObject* sao)
{
	if (!sao || !(sao->accessObjectProperties()))
		return nullptr;
	else
	{
		return sao->accessObjectProperties();
	}
}

bool NativeObjectRef::n_is_player(ServerActiveObject* sao)
{
	return (sao->getType() == ACTIVEOBJECT_TYPE_PLAYER);
}

int NativeObjectRef::n_set_nametag_attributes(ServerActiveObject *sao, const NametagAttributes& n)
{
	if (!sao || !(sao->accessObjectProperties()))
		return 0;
	else
	{
		ObjectProperties *prop = sao->accessObjectProperties();
		video::SColor nametagColor = prop->nametag_color;
		prop->nametag_color = n.color;

		if (n.has_bgcolor)
			prop->nametag_bgcolor = n.bgcolor;
		else
		{
			prop->nametag_bgcolor = nullopt;
		}
		prop->nametag = n.nametag;
		sao->notifyObjectPropertiesModified();
		return 1;
	}
}

NativeObjectRef::NametagAttributes NativeObjectRef::n_get_nametag_attributes(ServerActiveObject *sao)
{
	NativeObjectRef::NametagAttributes n;
	if (!sao)
		return n;
	ObjectProperties *prop = sao->accessObjectProperties();
	if (!prop)
		return n; 
	n.color = prop->nametag_color;
	if (prop->nametag_bgcolor)
	{
		n.has_bgcolor = true;
		n.bgcolor = prop->nametag_bgcolor.value();
	}
	n.nametag = prop->nametag;
	return n;
}

void NativeObjectRef::n_set_velocity(LuaEntitySAO* sao, const v3f& vel)
{
	if (sao)
		sao->setVelocity(vel);
}

void NativeObjectRef::n_add_velocity(Server* server, ServerActiveObject* sao, const v3f& vel)
{
	if (sao)
	{
		if (sao->getType() == ACTIVEOBJECT_TYPE_LUAENTITY) {
			LuaEntitySAO *entitysao = dynamic_cast<LuaEntitySAO *>(sao);
			entitysao->addVelocity(vel);
		} else if (sao->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
			PlayerSAO *playersao = dynamic_cast<PlayerSAO *>(sao);
			playersao->setMaxSpeedOverride(vel);
			server->SendPlayerSpeed(playersao->getPeerID(), vel);
		}
	}
}

v3f NativeObjectRef::n_get_velocity(ServerActiveObject* sao)
{
	if (sao->getType() == ACTIVEOBJECT_TYPE_LUAENTITY) {
		LuaEntitySAO *entitysao = dynamic_cast<LuaEntitySAO *>(sao);
		return entitysao->getVelocity();
	} else if (sao->getType() == ACTIVEOBJECT_TYPE_PLAYER) {
		RemotePlayer *player = dynamic_cast<PlayerSAO *>(sao)->getPlayer();
		return player->getSpeed();
	}
}

void NativeObjectRef::n_set_acceleration(LuaEntitySAO* sao, const v3f& acc)
{
	if (sao)
		sao->setAcceleration(acc);
}

v3f NativeObjectRef::n_get_acceleration(LuaEntitySAO* sao)
{
	if (sao)
		return sao->getAcceleration();
}

void NativeObjectRef::n_set_rotation(LuaEntitySAO *sao, const v3f &rot)
{
	if (sao)
		sao->setRotation(rot);
}

v3f NativeObjectRef::n_get_rotation(const LuaEntitySAO *sao)
{
	if (sao)
		return sao->getRotation();
}

void NativeObjectRef::n_set_yaw(LuaEntitySAO* sao, const float yaw)
{
	if (sao)
		sao->setRotation(v3f(0, yaw, 0));
}


float NativeObjectRef::n_get_yaw(const LuaEntitySAO *sao)
{
	if (sao)
		return sao->getRotation().Y;
}

void NativeObjectRef::n_set_texture_mod(LuaEntitySAO* sao, const std::string& name)
{
	sao->setTextureMod(name);
}

std::string NativeObjectRef::n_get_texture_mod(const LuaEntitySAO *sao)
{
	if (sao)
		return sao->getTextureMod();
}

void NativeObjectRef::n_set_sprite(LuaEntitySAO* sao, const v2s16& start_frame,
	const int num_frames, const float framelength,
	const bool select_x_by_camera)
{
	if (sao)
		sao->setSprite(start_frame, num_frames, framelength, select_x_by_camera);
}

std::string NativeObjectRef::n_get_entity_name(LuaEntitySAO* sao)
{
	return sao->getName();
}

int NativeObjectRef::n_get_luaentity(LuaEntitySAO* sao)
{
	if (sao)
		return sao->getId();
	return -1;
}

std::string NativeObjectRef::n_get_player_name(RemotePlayer* player)
{
	return player->getName();
}

v3f NativeObjectRef::n_get_look_dir(PlayerSAO *player)
{
	float pitch = player->getRadLookPitchDep();
	float yaw = player->getRadYawDep();
	v3f v(std::cos(pitch) * std::cos(yaw), std::sin(pitch),
			std::cos(pitch) * std::sin(yaw));
	return v;
}

f32 NativeObjectRef::n_get_look_pitch(PlayerSAO* sao)
{
	return sao->getRadLookPitchDep();
}

f32 NativeObjectRef::n_get_look_yaw(PlayerSAO* sao)
{
	return sao->getRadYawDep();
}

f32 NativeObjectRef::n_get_look_vertical(PlayerSAO* sao)
{
	return sao->getRadLookPitch();
}

f32 NativeObjectRef::n_get_look_horizontal(PlayerSAO* sao)
{
	return sao->getRadRotation().Y;
}

void NativeObjectRef::n_set_look_vertical(PlayerSAO* sao, const float pitch)
{
	if (sao)
		sao->setLookPitchAndSend(pitch);
}

void NativeObjectRef::n_set_look_horizontal(PlayerSAO* sao, const float yaw)
{
	if (sao)
		sao->setPlayerYawAndSend(yaw);
}

void NativeObjectRef::n_set_look_pitch(PlayerSAO *sao, const float pitch)
{
	if (sao)
		sao->setLookPitchAndSend(pitch);
}

void NativeObjectRef::n_set_look_yaw(PlayerSAO *sao, const float yaw)
{
	if (sao)
		sao->setPlayerYawAndSend(yaw);
}

void NativeObjectRef::n_set_fov(RemotePlayer *player, Server *server, const PlayerFovSpec &fov)
{
	player->setFov(fov);
	server->SendPlayerFov(player->getPeerId());
}

PlayerFovSpec NativeObjectRef::n_get_fov(RemotePlayer* player)
{
	return player->getFov();
}

void NativeObjectRef::n_set_player_breath(PlayerSAO *sao, const u16 breath)
{
	if (sao)
		sao->setBreath(breath);
}

u16 NativeObjectRef::n_get_breath(PlayerSAO* sao)
{
	return sao->getBreath();
}

void NativeObjectRef::n_set_attribute(PlayerSAO *sao, const std::string &attr, const bool removeString, std::string value)
{
	if (removeString)
	{
		sao->getMeta().removeString(attr);
	}
	else
	{
		sao->getMeta().setString(attr, value);
	}
}
//works same way as line of code it replaces, transferring value to string and using bool to denote operation success
bool NativeObjectRef::n_get_attribute(PlayerSAO* sao, const std::string& attr, std::string& value)
{
	return sao->getMeta().getStringToRef(attr, value);
}

Metadata* NativeObjectRef::n_get_meta(PlayerSAO* sao)
{
	Metadata *m = nullptr;
	if (sao)
		m = new Metadata(sao->getMeta());
	return m;
}

void NativeObjectRef::n_set_inventory_formspec(RemotePlayer* player, Server* server, const std::string& formspec)
{
	player->inventory_formspec = formspec;
	server->reportInventoryFormspecModified(player->getName());
}

std::string NativeObjectRef::n_get_inventory_formspec(RemotePlayer* player)
{
	return player->inventory_formspec;
}

void NativeObjectRef::n_set_formspec_prepend(RemotePlayer* player, Server* server, const std::string& formspec_prepend)
{
	if (player)
	{
		player->formspec_prepend = formspec_prepend;
		server->reportFormspecPrependModified(player->getName());
	}
}

std::string NativeObjectRef::n_get_formspec_prepend(RemotePlayer* player)
{
	return player->formspec_prepend;
}

PlayerControl* NativeObjectRef::n_get_player_control(RemotePlayer* player)
{
	PlayerControl* pc = nullptr;
	if (player)
		pc = new PlayerControl(player->getPlayerControl());
	return pc;
}

u32* NativeObjectRef::n_get_player_control_bits(RemotePlayer* player)
{
	u32 *ctrlBits = nullptr;
	if (player)
		ctrlBits = &player->keyPressed;
	return ctrlBits;
}

void NativeObjectRef::n_set_physics_override(PlayerSAO *sao, const PhysicsOverride &p)
{
	sao->m_physics_override_speed = p.speed;
	sao->m_physics_override_jump = p.jump;
	sao->m_physics_override_gravity = p.gravity;
	sao->m_physics_override_sneak = p.sneak;
	sao->m_physics_override_sneak_glitch = p.sneak_glitch;
	sao->m_physics_override_new_move = p.new_move;
}

NativeObjectRef::PhysicsOverride NativeObjectRef::n_get_physics_override(PlayerSAO *sao)
{
	PhysicsOverride p;
	p.speed = sao->m_physics_override_speed;
	p.jump = sao->m_physics_override_jump;
	p.gravity = sao->m_physics_override_gravity;
	p.sneak = sao->m_physics_override_sneak;
	p.sneak_glitch = sao->m_physics_override_sneak_glitch;
	p.new_move = sao->m_physics_override_new_move;
	return p;
}

u32 NativeObjectRef::n_hud_add(Server* server, RemotePlayer* player, HudElement* elem)
{
	u32 id = server->hudAdd(player, elem);
	if (id == U32_MAX)
		delete elem;
	
	return id;
}

bool NativeObjectRef::n_hud_remove(Server *server, RemotePlayer *player, const u32 id)
{
	return server->hudRemove(player, id);
}

void NativeObjectRef::n_hud_change(Server* server, RemotePlayer* player, const u32 id, HudElementStat& stat, void* value)
{
	server->hudChange(player, id, stat, value);
}

HudElement* NativeObjectRef::n_hud_get(RemotePlayer* player, const u32 id)
{
	HudElement *he = nullptr;
	if (!player)
		return he;
	he = player->getHud(id);
	return he;
}

bool NativeObjectRef::n_hud_set_flags(Server *server, RemotePlayer *player, const u32 flags, const u32 mask)
{
	return server->hudSetFlags(player, flags, mask);
}

u32 NativeObjectRef::n_hud_get_flags(RemotePlayer* player)
{
	return player->hud_flags;
}

bool NativeObjectRef::n_hud_set_hotbar_itemcount(Server *server, RemotePlayer *player, const s32 hotbar_itemcount)
{
	return server->hudSetHotbarItemcount(player, hotbar_itemcount);
}

s32 NativeObjectRef::n_hud_get_hotbar_itemcount(RemotePlayer *player)
{
	if (player)
		return player->getHotbarItemcount();
	return -1;
}

int NativeObjectRef::n_hud_set_hotbar_image(Server* server, RemotePlayer* player, const std::string& name)
{
	if (!player)
		return 0;
	server->hudSetHotbarImage(player, name);
	return 1;
}

std::unique_ptr<std::string> NativeObjectRef::n_hud_get_hotbar_image(RemotePlayer* player)
{
	std::unique_ptr<std::string> image;
	if (player)
		image = std::make_unique<std::string>(player->getHotbarImage());
	return image;
}

int NativeObjectRef::n_hud_set_hotbar_selected_image(Server* server, RemotePlayer* player, const std::string& name)
{
	if (!server || !player)
		return 0;
	server->hudSetHotbarSelectedImage(player, name);
	return 1;
}

std::unique_ptr<std::string> NativeObjectRef::n_hud_get_hotbar_selected_image(RemotePlayer* player)
{
	std::unique_ptr<std::string> image;
	if (player)
		image = std::make_unique<std::string>(player->getHotbarSelectedImage());
	return image;
}

void NativeObjectRef::n_set_sky(Server* server, RemotePlayer* player,const SkyboxParams& sky_params)
{
	server->setSky(player, sky_params);
}


SkyboxParams NativeObjectRef::n_get_sky(RemotePlayer *player)
{
	return player->getSkyParams();
}

//does the same thing as above to avoid overhead of calling multiple functions for when colors only in skyparams are returned
SkyboxParams NativeObjectRef::n_get_sky_color(RemotePlayer *player)
{
	return player->getSkyParams();
}

bool NativeObjectRef::n_set_sun(Server *server, RemotePlayer *player, const SunParams &s)
{
	if (!server || !player)
		return false;
	server->setSun(player, s);
	return true;
}

SunParams NativeObjectRef::n_get_sun(RemotePlayer* player)
{
	return player->getSunParams();
}

bool NativeObjectRef::n_set_moon(Server *server, RemotePlayer *player, const MoonParams &m)
{
	if (!server || !player)
		return false;
	server->setMoon(player, m);
	return true;
}

MoonParams NativeObjectRef::n_get_moon(RemotePlayer *player)
{
	return player->getMoonParams();
}

bool NativeObjectRef::n_set_stars(Server *server, RemotePlayer *player, const StarParams &s)
{
	if (!server || !player)
		return false;
	server->setStars(player, s);
	return true;
}

StarParams NativeObjectRef::n_get_stars(RemotePlayer *player)
{
	return player->getStarParams();
}

bool NativeObjectRef::n_set_clouds(Server *server, RemotePlayer *player, const CloudParams &c)
{
	if (!server || !player)
		return false;
	server->setClouds(player, c);
	return true;
}

CloudParams NativeObjectRef::n_get_clouds(RemotePlayer *player)
{
	return player->getCloudParams();
}

bool NativeObjectRef::n_override_day_night_ratio(Server* server, RemotePlayer* player, const bool do_override, const float ratio)
{
	if (!server || !player)
		return false;

	server->overrideDayNightRatio(player, do_override, ratio);
	return true;
}

bool NativeObjectRef::n_get_day_night_ratio(RemotePlayer *player, bool &do_override, float &ratio)
{
	if (!player)
		return false;

	player->getDayNightRatio(&do_override, &ratio);
	return true;
}

void NativeObjectRef::n_set_minimap_modes(Server *server, RemotePlayer* player, std::vector<MinimapMode> &minimap_modes, const s16 selected_mode)
{
	server->SendMinimapModes(player->getPeerId(), minimap_modes, selected_mode);
}