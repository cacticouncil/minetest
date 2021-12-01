#pragma once

#include "lua_api/l_base.h"
#include "tileanimation.h"
#include "irr_v3d.h"
#include "server.h"

class NativeApiParticles
{
private:
	static int native_add_particle(Server *_server, v3f *_pos = nullptr,
			v3f *_vel = nullptr, v3f *_acc = nullptr,
			float *_expirationtime = nullptr, float *_size = nullptr,
			bool *_collisiondetection = nullptr,
			bool *_collision_removal = nullptr,
			bool *_object_collision = nullptr, bool *_vertical = nullptr,
			TileAnimationParams *_animation = nullptr,
			std::string *_texture = nullptr,
			std::string *_playername = nullptr, u8 *_glow = nullptr);
	static u32 native_add_particlespawner(Server *_server, u16 *_amount = nullptr,
			v3f *_minpos = nullptr, v3f *_maxpos = nullptr,
			v3f *_minvel = nullptr, v3f *_maxvel = nullptr,
			v3f *_minacc = nullptr, v3f *_maxacc = nullptr,
			float *_time = nullptr, float *_minexptime = nullptr,
			float *_maxexptime = nullptr, float *_minsize = nullptr,
			float *_maxsize = nullptr, bool *_collisiondetection = nullptr,
			bool *_collision_removal = nullptr,
			bool *_object_collision = nullptr, bool *_vertical = nullptr,
			TileAnimationParams *_animation = nullptr,
			std::string *_texture = nullptr,
			ServerActiveObject *_attached = nullptr,
			std::string *_playername = nullptr, u8 *_glow = nullptr);
	static int native_delete_particlespawner(
			u32 _id, std::string _playername, Server *_server);
};
