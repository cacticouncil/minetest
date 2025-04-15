#include "native_base.h"
#include "remoteplayer.h"
#include "../server/player_sao.h"
#include "../server/luaentity_sao.h"
#include "metadata.h"
#include <memory>
#include <tuple>

class NativeObjectRef : public NativeModApiBase
{
public:
	struct NametagAttributes
	{
		video::SColor color;
		video::SColor bgcolor;
		std::string nametag;
		bool has_bgcolor = false;
	};
	//default values from lua_api.txt
	struct PhysicsOverride
	{
		float speed = 1.0;
		float jump = 1.0;
		float gravity = 1.0;
		bool sneak = true;
		bool sneak_glitch = false;
		bool new_move= true;
		bool override_sent = false;
	};
	static void n_remove(ServerActiveObject *sao);
	static std::unique_ptr<v3f> n_get_pos(const ServerActiveObject *sao);
	static void n_set_pos(ServerActiveObject *sao, const v3f &pos);
	static void n_move_to(
			ServerActiveObject *sao, const v3f &pos, const bool continuous);
	static std::unique_ptr<u16> n_punch(Server* server, ServerActiveObject *puncher,
			ServerActiveObject *punchee, const ToolCapabilities &tc,
			const v3f &dir, const float time_from_last_punch);
	static void n_right_click(
			ServerActiveObject *clicker, ServerActiveObject *clickee);
	static void n_set_hp(Server* server, ServerActiveObject *sao, const int hp);
	static int n_get_hp(ServerActiveObject *sao);
	static InventoryLocation n_get_inventory(ServerActiveObject *sao);
	static std::unique_ptr<std::string> n_get_wield_list(
			const ServerActiveObject *sao);
	static int n_get_wield_index(const ServerActiveObject *sao);
	static bool n_set_wielded_item(Server* server, ServerActiveObject *sao, ItemStack &item);
	static bool n_set_armor_groups(ServerActiveObject *sao, ItemGroupList &groups);
	static std::unique_ptr<ItemGroupList> n_get_armor_groups(
			const ServerActiveObject *sao);
	static void n_set_animation(ServerActiveObject *sao, const v2f frame_range,
			const float frame_speed, const float frame_blend,
			const bool frame_loop);
	static int n_get_animation(ServerActiveObject *sao, v2f &frames,
			float &frame_speed, float &frame_blend, bool &frame_loop);
	static bool n_set_local_animation(Server *server, RemotePlayer *player,
			 v2s32 frames[], const f32 frame_speed);
	static int n_get_local_animation(RemotePlayer *player, v2s32 *frames, float& frame_speed);
	static int n_set_eye_offset(Server *server, RemotePlayer *player,
			const v3f &offset_first, const v3f &offset_third);
	static v3f *n_get_eye_offset(RemotePlayer *player);
	static bool n_send_mapblock(
			Server *server, const session_t &peerId, const v3s16 &pos);
	static void n_set_animation_frame_speed(ServerActiveObject *sao, const float& frame_speed);
	static void n_set_bone_position(ServerActiveObject *sao, const std::string &bone,
			const v3f &position, const v3f &rotation);
	static void n_get_bone_position(ServerActiveObject *sao, const std::string& bone,
			v3f &position, v3f &rotation);
	static void n_set_attach(ServerActiveObject *parent,
			ServerActiveObject *attachment, const std::string &bone,
			const v3f &position, const v3f &rotation,
			const bool &force_visible);
	static int n_get_attach(ServerActiveObject* sao, int &parent_id, std::string &bone, v3f &position,
			v3f &rotation, bool &force_visible);
	static std::unique_ptr<std::unordered_set<int>> n_get_children(ServerActiveObject *sao);
	static void n_set_detach(ServerActiveObject *sao);
	static void n_set_properties(ServerActiveObject *sao);
	static ObjectProperties* n_get_properties(ServerActiveObject *sao);
	static bool n_is_player(ServerActiveObject* sao);
	static int n_set_nametag_attributes(ServerActiveObject *sao, const NametagAttributes& n);
	static NametagAttributes n_get_nametag_attributes(ServerActiveObject *sao);
	static void n_set_velocity(LuaEntitySAO* sao, const v3f &vel);
	static void n_add_velocity(Server* server, ServerActiveObject* sao, const v3f &vel);
	static v3f n_get_velocity(ServerActiveObject *sao);
	static void n_set_acceleration(LuaEntitySAO *sao, const v3f &acc);
	static v3f n_get_acceleration(LuaEntitySAO *sao);
	static void n_set_rotation(LuaEntitySAO *sao, const v3f& rot);
	static v3f n_get_rotation(const LuaEntitySAO *sao);
	static void n_set_yaw(LuaEntitySAO *sao, const float yaw);
	static float n_get_yaw(const LuaEntitySAO *sao);
	static void n_set_texture_mod(LuaEntitySAO *sao, const std::string &name);
	static std::string n_get_texture_mod(const LuaEntitySAO *sao);
	static void n_set_sprite(LuaEntitySAO *sao, const v2s16 &start_frame,
			const int num_frames, const float framelength,
			const bool select_x_by_camera);
	static std::string n_get_entity_name(LuaEntitySAO *sao);
	static int n_get_luaentity(LuaEntitySAO* sao);
	static std::string n_get_player_name(RemotePlayer *player);
	static v3f n_get_look_dir(PlayerSAO *sao);
	static f32 n_get_look_pitch(PlayerSAO *sao);
	static f32 n_get_look_yaw(PlayerSAO *sao);
	static f32 n_get_look_vertical(PlayerSAO *sao);
	static f32 n_get_look_horizontal(PlayerSAO *sao);
	static void n_set_look_vertical(PlayerSAO *sao, const float pitch);
	static void n_set_look_horizontal(PlayerSAO *sao, const float yaw);
	static void n_set_look_pitch(PlayerSAO *sao, const float pitch);
	static void n_set_look_yaw(PlayerSAO *sao, const float yaw);
	static void n_set_fov(RemotePlayer *player, Server* server, const PlayerFovSpec &fov);
	static PlayerFovSpec n_get_fov(RemotePlayer *player);
	static void n_set_player_breath(PlayerSAO* sao, const u16 breath);
	static u16 n_get_breath(PlayerSAO *sao);
	static void n_set_attribute(PlayerSAO *sao, const std::string &attr, const bool removeString, std::string value = "");
	static bool n_get_attribute(PlayerSAO *sao, const std::string &attr, std::string &value);
	static Metadata* n_get_meta(PlayerSAO *sao);
	static void n_set_inventory_formspec(RemotePlayer *player, Server *server, const std::string &formspec);
	static std::string n_get_inventory_formspec(RemotePlayer *player);
	static void n_set_formspec_prepend(RemotePlayer *player, Server *server,const std::string &formspec_prepend);
	static std::string n_get_formspec_prepend(RemotePlayer *player);
	static PlayerControl* n_get_player_control(RemotePlayer *player);
	static u32* n_get_player_control_bits(RemotePlayer *player);
	static void n_set_physics_override(PlayerSAO* sao, const PhysicsOverride &p);
	static PhysicsOverride n_get_physics_override(PlayerSAO *sao);
	static u32 n_hud_add(Server *server, RemotePlayer *player, HudElement *elem);
	static bool n_hud_remove(Server *server, RemotePlayer *player, const u32 id);
	static void n_hud_change(Server *server, RemotePlayer *player, const u32 id, HudElementStat &stat, void *value);
	static HudElement *n_hud_get(RemotePlayer *player, const u32 id);
	static bool n_hud_set_flags(Server *server, RemotePlayer *player, const u32 flags, const u32 mask);
	static u32 n_hud_get_flags(RemotePlayer *player);
	static bool n_hud_set_hotbar_itemcount(Server *server, RemotePlayer *player, const s32 hotbar_itemcount);
	static s32 n_hud_get_hotbar_itemcount(RemotePlayer *player);
	static int n_hud_set_hotbar_image(Server *server, RemotePlayer *player, const std::string &name);
	static std::unique_ptr<std::string> n_hud_get_hotbar_image(RemotePlayer *player);
	static int n_hud_set_hotbar_selected_image(Server *server, RemotePlayer *player, const std::string &name);
	static std::unique_ptr<std::string> n_hud_get_hotbar_selected_image(RemotePlayer *player);
	static void n_set_sky(Server* server, RemotePlayer* player, const SkyboxParams& sky_params);
	static SkyboxParams n_get_sky(RemotePlayer* player);
	static SkyboxParams n_get_sky_color(RemotePlayer *player);
	static bool n_set_sun(Server *server, RemotePlayer *player, const SunParams &s);
	static SunParams n_get_sun(RemotePlayer *player);
	static bool n_set_moon(Server *server, RemotePlayer *player, const MoonParams& m);
	static MoonParams n_get_moon(RemotePlayer *player);
	static bool n_set_stars(Server *server, RemotePlayer *player, const StarParams &s);
	static StarParams n_get_stars(RemotePlayer *player);
	static bool n_set_clouds(Server *server, RemotePlayer *player, const CloudParams &c);
	static CloudParams n_get_clouds(RemotePlayer *player);
	static bool n_override_day_night_ratio(Server *server, RemotePlayer *player, const bool do_override, const float ratio);
	static bool n_get_day_night_ratio(RemotePlayer *player, bool &do_override, float& ratio);
	static void n_set_minimap_modes(Server* server, RemotePlayer* player, std::vector<MinimapMode>& minimap_modes, const s16 selected_mode);

};