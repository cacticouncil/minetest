#include "native_camera.h"
#include <cmath>
#include "client/content_cao.h"
#include <tuple>
#include "client/camera.h"
#include "client/client.h"

int NativeCamera::native_set_camera_mode(Camera *camera, Client *client, int *val)
{
	GenericCAO *playercao = client->getEnv().getLocalPlayer()->getCAO();
	sanity_check(playercao);

	camera->setCameraMode((CameraMode)(*val));
	playercao->setVisible(camera->getCameraMode() > CAMERA_MODE_FIRST);
	playercao->setChildrenVisible(camera->getCameraMode() > CAMERA_MODE_FIRST);

	return 1;
}

int NativeCamera::native_get_camera_mode(Camera *camera)
{
	int camMode = (int)camera->getCameraMode();

	return camMode;
}

std::tuple<f32, f32, f32, f32> NativeCamera::native_get_fov(Camera *camera)
{
	f32 x = camera->getFovX() * core::DEGTORAD;
	f32 y = camera->getFovY() * core::DEGTORAD;
	f32 actual = camera->getCameraNode()->getFOV() * core::RADTODEG;
	f32 max = camera->getFovMax() * core::RADTODEG;

	// TODO: Save these fov values somewhere
	return std::tuple<f32, f32, f32, f32>(x, y, actual, max);
}

v3f NativeCamera::native_get_pos(Camera *camera)
{
	v3f position = camera->getPosition();

	return position;
}

v3f NativeCamera::native_get_offset(Camera *camera)
{
	v3f offset = camera->getPosition();

	return offset;
}

v3f NativeCamera::native_get_look_dir(Client *client)
{
	LocalPlayer *player = client->getEnv().getLocalPlayer();
	sanity_check(player);

	float pitch = -1.0 * player->getPitch() * core::DEGTORAD;
	float yaw = (player->getYaw() + 90.) * core::DEGTORAD;
	v3f lookDir(std::cos(pitch) * std::cos(yaw), std::sin(pitch),
			std::cos(pitch) * std::sin(yaw));

	return lookDir;
}

f32 NativeCamera::native_get_look_horizontal(Client *client)
{
	LocalPlayer *player = client->getEnv().getLocalPlayer();
	sanity_check(player);

	f32 lookHorizontal = (player->getYaw() + 90.) * core::DEGTORAD;

	return lookHorizontal;
}

f32 NativeCamera::native_get_look_vertical(Client *client)
{
	LocalPlayer *player = client->getEnv().getLocalPlayer();
	sanity_check(player);

	f32 lookVertical = -1.0 * player->getPitch() * core::DEGTORAD;

	return lookVertical;
}

f32 NativeCamera::native_get_aspect_ratio(Camera *camera)
{
	f32 aspectRatio = camera->getCameraNode()->getAspectRatio();

	return aspectRatio;
}