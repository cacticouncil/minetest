#include "native_particles_local.h"
#include "common/c_content.h"
#include "common/c_converter.h"
#include "lua_api/l_internal.h"
#include "lua_api/l_object.h"
#include "client/particles.h"
#include "client/client.h"
#include "client/clientevent.h"

int NativeApiParticlesLocal::native_add_particle(Client *_client, v3f *_pos, v3f *_vel,
		v3f *_acc, float *_expirationtime, float *_size,
		bool *_collisiondetection, bool *_collision_removal, bool *_vertical,
		TileAnimationParams *_animation, std::string *_texture, u8 *_glow)
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
	bool vertical = (_vertical != nullptr) ? *_vertical : false;

	struct TileAnimationParams animation = *_animation;
	animation.type = TAT_NONE;

	std::string texture = (_texture != nullptr) ? *_texture : "";
	u8 glow = (_glow != nullptr) ? *_glow : 0;

	ClientEvent *event = new ClientEvent();
	event->type = CE_SPAWN_PARTICLE;
	event->spawn_particle.pos = new v3f(pos);
	event->spawn_particle.vel = new v3f(vel);
	event->spawn_particle.acc = new v3f(acc);
	event->spawn_particle.expirationtime = expirationtime;
	event->spawn_particle.size = size;
	event->spawn_particle.collisiondetection = collisiondetection;
	event->spawn_particle.collision_removal = collision_removal;
	event->spawn_particle.vertical = vertical;
	event->spawn_particle.texture = new std::string(texture);
	event->spawn_particle.animation = animation;
	event->spawn_particle.glow = glow;

	_client->pushToEventQueue(event);

	return 0;
}

int NativeApiParticlesLocal::native_add_particlespawner(Client *_client, u16 *_amount,
		v3f *_minpos, v3f *_maxpos, v3f *_minvel, v3f *_maxvel, v3f *_minacc,
		v3f *_maxacc, float *_time, float *_minexptime, float *_maxexptime,
		float *_minsize, float *_maxsize, bool *_collisiondetection,
		bool *_vertical, bool *_collision_removal,
		TileAnimationParams *_animation, std::string *_texture, u8 *_glow)
{
	// Get parameters
	u16 amount = (_amount != nullptr) ? *_amount : 1;

	float time = (_time != nullptr) ? *_time : 1.0f;

	v3f minpos = (_minpos != nullptr) ? *_minpos : v3f(0, 0, 0);
	v3f maxpos = (_maxpos != nullptr) ? *_maxpos : v3f(0, 0, 0);
	v3f minvel = (_minvel != nullptr) ? *_minvel : v3f(0, 0, 0);
	v3f maxvel = (_maxvel != nullptr) ? *_maxvel : v3f(0, 0, 0);
	v3f minacc = (_minacc != nullptr) ? *_minacc : v3f(0, 0, 0);
	v3f maxacc = (_maxacc != nullptr) ? *_maxacc : v3f(0, 0, 0);

	float minexptime = (_minexptime != nullptr) ? *_minexptime : 1.0f;
	float maxexptime = (_maxexptime != nullptr) ? *_maxexptime : 1.0f;
	float minsize = (_minsize != nullptr) ? *_minsize : 1.0f;
	float maxsize = (_maxsize != nullptr) ? *_maxsize : 1.0f;

	bool collisiondetection =
			(_collisiondetection != nullptr) ? *_collisiondetection : false;
	bool collision_removal =
			(_collision_removal != nullptr) ? *_collision_removal : false;
	bool vertical = (_vertical != nullptr) ? *_vertical : false;

	struct TileAnimationParams animation = *_animation;
	animation.type = TAT_NONE;

	std::string texture = (_texture != nullptr) ? *_texture : "";
	u8 glow = (_glow != nullptr) ? *_glow : 0;

	u64 id = _client->getParticleManager()->generateSpawnerId();

	auto event = new ClientEvent();
	event->type = CE_ADD_PARTICLESPAWNER;
	event->add_particlespawner.amount = amount;
	event->add_particlespawner.spawntime = time;
	event->add_particlespawner.minpos = new v3f(minpos);
	event->add_particlespawner.maxpos = new v3f(maxpos);
	event->add_particlespawner.minvel = new v3f(minvel);
	event->add_particlespawner.maxvel = new v3f(maxvel);
	event->add_particlespawner.minacc = new v3f(minacc);
	event->add_particlespawner.maxacc = new v3f(maxacc);
	event->add_particlespawner.minexptime = minexptime;
	event->add_particlespawner.maxexptime = maxexptime;
	event->add_particlespawner.minsize = minsize;
	event->add_particlespawner.maxsize = maxsize;
	event->add_particlespawner.collisiondetection = collisiondetection;
	event->add_particlespawner.collision_removal = collision_removal;
	event->add_particlespawner.attached_id = 0;
	event->add_particlespawner.vertical = vertical;
	event->add_particlespawner.texture = new std::string(texture);
	event->add_particlespawner.id = id;
	event->add_particlespawner.animation = animation;
	event->add_particlespawner.glow = glow;

	_client->pushToEventQueue(event);

	return 1;
}

int NativeApiParticlesLocal::native_delete_particlespawner(u32 _id, Client *_client)
{
	ClientEvent *event = new ClientEvent();
	event->type = CE_DELETE_PARTICLESPAWNER;
	event->delete_particlespawner.id = _id;

	_client->pushToEventQueue(event);
	return 0;
}