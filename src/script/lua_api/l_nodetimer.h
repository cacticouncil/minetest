/*
Minetest
Copyright (C) 2013 celeron55, Perttu Ahola <celeron55@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#pragma once

#include "irr_v3d.h"
#include "lua_api/l_base.h"

class ServerMap;

class NodeTimerRef : public ModApiBase
{
private:
	v3s16 m_p;
	ServerMap *m_map;

	static const char className[];
	static const luaL_Reg methods[];

	static int gc_object(lua_State *L);
	static NodeTimerRef *checkobject(lua_State *L, int narg);
	static int l_set(lua_State *L);
	static int l_start(lua_State *L);
	static int l_stop(lua_State *L);
	static int l_is_started(lua_State *L);
	static int l_get_timeout(lua_State *L);
	static int l_get_elapsed(lua_State *L);

	// new lua functions to call corresponding native functions
	static int l_native_set(lua_State *L);
	static int l_native_start(lua_State *L);
	static int l_native_stop(lua_State *L);
	static int l_native_is_started(lua_State *L);
	static int l_native_get_timeout(lua_State *L);
	static int l_native_get_elapsed(lua_State *L);

public:
	NodeTimerRef(v3s16 p, ServerMap *map) : m_p(p), m_map(map) {}
	~NodeTimerRef() = default;

	// Getter methods for private attributes
	v3s16 get_m_p(){return m_p;};
	ServerMap *get_m_map() { return m_map;};
	
	// Creates an NodeTimerRef and leaves it on top of stack
	// Not callable from Lua; all references are created on the C side.
	static void create(lua_State *L, v3s16 p, ServerMap *map);
	//Makes same engine changes but does not require Lua state
	static NodeTimerRef* native_create(v3s16 p, ServerMap *map);
	static void Register(lua_State *L);
};
