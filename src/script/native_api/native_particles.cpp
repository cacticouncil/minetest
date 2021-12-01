#include "native_particles.h"

int NativeApiParticles::native_add_particle(Server *_server, v3f *_pos, v3f *_vel,
		v3f *_acc, float *_expirationtime, float *_size,
		bool *_collisiondetection, bool *_collision_removal,
		bool *_object_collision, bool *_vertical, TileAnimationParams *_animation,
		std::string *_texture, std::string *_playername, u8 *_glow)
{
	// Get parameters
	v3f pos = (_pos != nullptr) ? *_pos : v3f(0, 0, 0);
	v3f vel = (_vel != nullptr) ? *_vel : v3f(0, 0, 0);
	v3f acc = (_acc != nullptr) ? *_acc : v3f(0, 0, 0);

	float expirationtime = (_expirationtime != nullptr) ? *_expirationtime : 1.0f;
	float size = (_size != nullptr) ? *_size : 1.0f;

	bool collisiondetection =
			(_collisiondetection != nullptr) ? *_collisiondetection : false;
	bool collision_removal =
			(_collision_removal != nullptr) ? *_collision_removal : false;
	bool object_collision =
			(_object_collision != nullptr) ? *_object_collision : false;
	bool vertical = (_vertical != nullptr) ? *_vertical : false;

	struct TileAnimationParams animation = *_animation;
	animation.type = TAT_NONE;

	std::string texture = (_texture != nullptr) ? *_texture : "";
	std::string playername = (_playername != nullptr) ? *_playername : "";
	u8 glow = (_glow != nullptr) ? *_glow : 0;

	_server->spawnParticle(playername, pos, vel, acc, expirationtime, size,
			collisiondetection, collision_removal, object_collision, vertical,
			texture, animation, glow);
	return 0;
}

u32 NativeApiParticles::native_add_particlespawner(Server *_server, u16 *_amount,
		v3f *_minpos, v3f *_maxpos, v3f *_minvel, v3f *_maxvel, v3f *_minacc,
		v3f *_maxacc, float *_time, float *_minexptime, float *_maxexptime,
		float *_minsize, float *_maxsize, bool *_collisiondetection,
		bool *_collision_removal, bool *_object_collision, bool *_vertical,
		TileAnimationParams *_animation, std::string *_texture,
		ServerActiveObject *_attached, std::string *_playername, u8 *_glow)
{
	// Get parameters
	u16 amount = (_amount != nullptr) ? *_amount : 1;

	v3f minpos = (_minpos != nullptr) ? *_minpos : v3f(0, 0, 0);
	v3f maxpos = (_maxpos != nullptr) ? *_maxpos : v3f(0, 0, 0);
	v3f minvel = (_minvel != nullptr) ? *_minvel : v3f(0, 0, 0);
	v3f maxvel = (_maxvel != nullptr) ? *_maxvel : v3f(0, 0, 0);
	v3f minacc = (_minacc != nullptr) ? *_minacc : v3f(0, 0, 0);
	v3f maxacc = (_maxacc != nullptr) ? *_maxacc : v3f(0, 0, 0);

	float time = (_time != nullptr) ? *_time : 1.0f;
	float minexptime = (_minexptime != nullptr) ? *_minexptime : 1.0f;
	float maxexptime = (_maxexptime != nullptr) ? *_maxexptime : 1.0f;
	float minsize = (_minsize != nullptr) ? *_minsize : 1.0f;
	float maxsize = (_maxsize != nullptr) ? *_maxsize : 1.0f;

	bool collisiondetection =
			(_collisiondetection != nullptr) ? *_collisiondetection : false;
	bool collision_removal =
			(_collision_removal != nullptr) ? *_collision_removal : false;
	bool object_collision =
			(_object_collision != nullptr) ? *_object_collision : false;
	bool vertical = (_vertical != nullptr) ? *_vertical : false;

	struct TileAnimationParams animation = *_animation;
	animation.type = TAT_NONE;

	std::string texture = (_texture != nullptr) ? *_texture : "";
	std::string playername = (_playername != nullptr) ? *_playername : "";
	u8 glow = (_glow != nullptr) ? *_glow : 0;

	// Get parameters

	ServerActiveObject *attached = (_attached != nullptr) ? _attached : NULL;

	return _server->addParticleSpawner(amount, time, minpos, maxpos, minvel, maxvel,
			minacc, maxacc, minexptime, maxexptime, minsize, maxsize,
			collisiondetection, collision_removal, object_collision, attached,
			vertical, texture, playername, animation, glow);
}

int NativeApiParticles::native_delete_particlespawner(
		u32 _id, std::string _playername, Server *_server)
{
	_server->deleteParticleSpawner(_playername, _id);
	return 0;
}