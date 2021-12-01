#include "lua_api/l_base.h"
#include "tileanimation.h"
#include "irr_v3d.h"

class NativeApiParticlesLocal
{
private:
	int native_add_particle(Client *_client, v3f *_pos, v3f *_vel, v3f *_acc,
			float *_expirationtime, float *_size, bool *_collisiondetection,
			bool *_collision_removal, bool *_vertical,
			TileAnimationParams *_animation, std::string *_texture,
			u8 *_glow);
	static int native_add_particlespawner(Client *_client, u16 *_amount = nullptr,
			v3f *_minpos = nullptr, v3f *_maxpos = nullptr,
			v3f *_minvel = nullptr, v3f *_maxvel = nullptr,
			v3f *_minacc = nullptr, v3f *_maxacc = nullptr,
			float *_time = nullptr, float *_minexptime = nullptr,
			float *_maxexptime = nullptr, float *_minsize = nullptr,
			float *_maxsize = nullptr, bool *_collisiondetection = nullptr,
			bool *_vertical = nullptr, bool *_collision_removal = nullptr,
			TileAnimationParams *_animation = nullptr,
			std::string *_texture = nullptr, u8 *_glow = nullptr);
	static int native_delete_particlespawner(u32 _id, Client *_client);
};
