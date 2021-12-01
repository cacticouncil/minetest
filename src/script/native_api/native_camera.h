#pragma once
#include "irr_v3d.h"
#include <tuple>
#include "client/client.h"

class Camera;

class NativeCamera
{
private:
	static int native_set_camera_mode(Camera *camera, Client *client, int *val);
	static int native_get_camera_mode(Camera *camera);
	static std::tuple<f32, f32, f32, f32> native_get_fov(Camera *camera);
	static v3f native_get_pos(Camera *camera);
	static v3f native_get_offset(Camera *camera);
	static v3f native_get_look_dir(Client *client);
	static f32 native_get_look_horizontal(Client *client);
	static f32 native_get_look_vertical(Client *client);
	static f32 native_get_aspect_ratio(Camera *camera);
};
