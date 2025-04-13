minetest.log("info", "[testing] modname="..dump(minetest.get_current_modname()))
minetest.log("info", "[testing] modpath="..dump(minetest.get_modpath("testingnativeapi_server")))
--get HTTP Api for testing
HTTPApiTable = core.request_http_api()
NativeHTTPApiTable = core.native_request_http_api()

minetest.register_on_mods_loaded(function()
	minetest.log("action", "[testing] on_mods_loaded()")
end)

local modpath = minetest.get_modpath("testingnativeapi_server")

-- Load test suite
native_tests = dofile(modpath .. "/native_tests.lua")

-- Load class files
dofile(modpath .. "/auth.lua")
dofile(modpath .. "/areastore.lua")
dofile(modpath .. "/inventory.lua")
dofile(modpath .. "/particles.lua")
dofile(modpath .. "/settings.lua")
dofile(modpath .. "/noise.lua")
dofile(modpath .. "/nodetimer.lua")
dofile(modpath .. "/modchannels.lua")
dofile(modpath .. "/itemstackmeta.lua")
dofile(modpath .. "/metadata.lua")
dofile(modpath .. "/vmanip.lua")
dofile(modpath .. "/rollback.lua")

dofile(modpath .. "/nodemeta.lua")
dofile(modpath .. "/util.lua")
dofile(modpath .. "/base.lua")
dofile(modpath .. "/http.lua")
dofile(modpath .. "/object.lua")
dofile(modpath .. "/mapgen.lua")
dofile(modpath ..  "/server.lua")
-- Load helper files
dofile(modpath .. "/other.lua")
dofile(modpath .. "/server_test.lua")
dofile(modpath .. "/client_tools.lua")



