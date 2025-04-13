--note: has only been tested on worlds named "mapgentest." You may need to write a utility that gets the current world name

--deletes map database on startup so that mapgen is always used on load
local modpath = core.get_modpath("testingnativeapi_server")

InitEnvVars = assert(loadfile(modpath.."/env.lua", "t"))
--env.lua contains path to selected test world (mapgentest)
InitEnvVars()
os.remove(_G["Path"])
CompareTables = _G["CompareTables"]
Log = _G["Log"]
os.remove("logfile.txt")
--collects data from APIs that only work on mapgen threads
MapgenObj = nil
NativeMapgenObj = nil
core.register_on_generated(
function(minp, maxp, blockseed)
    if MapgenObj == nil then MapgenObj = core.get_mapgen_object("voxelmanip") end
    if NativeMapgenObj == nil then NativeMapgenObj = core.native_get_mapgen_object("voxelmanip") end
end)

--functions that can only be called on init go here
local testParams = {mgname="flat", seed="3.343534634643243e+18", chunksize=4, water_level=0, flags="caves, dungeons, biomes"}
local defaultParams = {mgname="v7", seed="3.34353463463e+18", chunksize=5, water_level=1, flags="caves, dungeons, light, decorations, biomes, ores"}

local initialParams
local luaParams
local nativeParams
local nativeChanged_params = false
local luaChanged_params = false
local sameValue_params = false


--test set_mapgen_params
initialParams = core.get_mapgen_params()
core.set_mapgen_params(testParams)
luaParams = core.get_mapgen_params()
if dump(luaParams) ~= dump(initialParams) then luaChanged_params = true end
core.set_mapgen_params(defaultParams)

initialParams = core.get_mapgen_params()
core.native_set_mapgen_params(testParams)
nativeParams = core.get_mapgen_params()
if dump(nativeParams) ~= dump(initialParams) then nativeChanged_params = true end
core.native_set_mapgen_params(defaultParams)

sameValue_params = (dump(nativeParams) == dump(luaParams))

--test set_mapgen_setting by changing mapgen name
local initialSetting
local luaSetting
local nativeSetting
local nativeChanged_setting = false
local luaChanged_setting = false
local sameValue_setting

initialSetting = core.get_mapgen_setting("mgname")
core.set_mapgen_setting("mgname", testParams["mgname"], true)
luaSetting = core.get_mapgen_setting("mgname")
if initialSetting ~= luaSetting then luaChanged_setting = true end
core.set_mapgen_setting("mgname", defaultParams["mgname"], true)

initialSetting = core.get_mapgen_setting("mgname")
core.native_set_mapgen_setting("mgname", testParams["mgname"], true)
nativeSetting = core.get_mapgen_setting("mgname")
if initialSetting ~= nativeSetting then nativeChanged_setting = true end
core.native_set_mapgen_setting("mgname", defaultParams["mgname"], true)

sameValue_setting = (nativeSetting == luaSetting)

--test set_mapgen_setting_noiseparams by changing water_level noiseparams
local defaultNoiseparams = 
{ flags = "defaults",
scale = "0",
spread = {
x = "0",
y = "0",
z = "0",
},
seed=0,
offset = "1",
persistence = "0",
lacunarity = "2",
octaves = 0,
}

local testNoiseparams = 
{ flags = "defaults",
scale = "1",
spread = {
x = "2",
y = "5",
z = "3",
},
seed=3,
offset = "2",
persistence = "1",
lacunarity = "0",
octaves = 1, 
}

local initNoiseparams
local luaNoiseparams
local nativeNoiseparams
local luaChanged_noiseparams
local nativeChanged_noiseparams
local sameValue_noiseparams

initNoiseparams = core.get_mapgen_setting_noiseparams("water_level")
core.set_mapgen_setting_noiseparams("water_level", testNoiseparams, true)
luaNoiseparams = core.get_mapgen_setting_noiseparams("water_level")
if dump(initNoiseparams) ~= dump(luaNoiseparams) then luaChanged_noiseparams = true end
core.set_mapgen_setting_noiseparams("water_level", defaultNoiseparams, true)

initNoiseparams = core.get_mapgen_setting_noiseparams("water_level")
core.native_set_mapgen_setting_noiseparams("water_level", testNoiseparams, true) 
nativeNoiseparams = core.get_mapgen_setting_noiseparams("water_level")
if dump(nativeNoiseparams) ~= dump(initNoiseparams) then nativeChanged_noiseparams = true end
core.native_set_mapgen_setting_noiseparams("water_level", defaultNoiseparams, true)

sameValue_noiseparams = (dump(luaNoiseparams) == dump(nativeNoiseparams))

--test register_biome
local testBiome = {
    name = "testbiome",
    depth_top = 1,
    node_filler = "default:snowblock",
    depth_filler = 3,
    node_stone = "default:cave_ice",
    node_water_top = "default:ice",
    depth_water_top = 10,
    node_top = "default:snowblock",
    node_riverbed = "default:gravel",
    depth_riverbed = 5,
    node_dungeon = "default:ice",
    node_dungeon_stair = "stairs:stair_ice",
    heat_point = 23,
    humidity_point = 73,
    node_dust = "default:snowblock",
    node_river_water = "default:ice",
    y_max = 31000,
    y_min = -8
}

os.remove("biomes.txt")
local f = io.open("biomes.txt", "a+")

f:write(dump(core.registered_biomes).."\n")
local luaRes = core.register_biome(testBiome)
f:write(luaRes..dump(core.registered_biomes).."\n")
local luaRegisteredBiome
if core.registered_biomes["testbiome"] then luaRegisteredBiome = core.registered_biomes["testbiome"] end
core.clear_registered_biomes()
f:write(dump(core.registered_biomes).."\n")

local nativeRes = core.test_func(testBiome)
f:write(nativeRes..dump(core.registered_biomes).."\n")
local nativeRegisteredBiome
if core.registered_biomes["testbiome"] then nativeRegisteredBiome = core.registered_biomes["testbiome"] end
core.clear_registered_biomes()
f:write(dump(core.registered_biomes).."\n")

--[[
Attempted solutions/observations: 
lua works and native doesn't work when you swap the function bodies
lua works and native doesn't work when both have lua bodies
lua works and native doesn't work when both have native bodies
Test works if you use core.register_biome twice regardless of function body content
native function is registered with same macro as other, working functions
expanding macro doesn't work
behavior appears normal when stepping through debugger (table fields have correct values) and a valid handle is returned, but no biome is registered
registering the function also appears normal when stepping though debugger, with working references to native function
native function correctly returns nil if biome has already been registered
new function called "test_func" with copied and pasted lua function body did not work
changing the name of l_register_biome worked
changing the l_register_biome's registration macro to reference the native function worked.
changing l_native_get_biome_data's function registration to reference the original lua function did not work
checked if Lua function body had accidentally been modified, is identical to repository version before first Cacti Council commit
]]--
--test register_decoration

local testDeco = {
    deco_type = "simple",
    place_on = "default:stone",
    name = "testdeco",
    sidelen = 8,
    fill_ratio = 10,
    y_min = -31000,
    y_max = 31000,
    flags = "liquid_surface, force_placement, all_floors, all_ceilings",
    decoration = "default:goldblock",
    height = 1,
    height_max = 1,
}

local luaHandle = core.register_decoration(testDeco)
local luaDeco
if luaHandle then luaDeco = core.registered_decorations[luaHandle] end
core.clear_registered_decorations()

local nativeHandle = core.native_register_decoration(testDeco)
local nativeDeco
if nativeHandle then nativeDeco = core.registered_decorations[nativeHandle] end
core.clear_registered_decorations()


--test register_ore

local testOre = {
    name = "testore",
    y_max = 10,
    wherein = "default:stone",
    y_min = -31000,
    clust_scarcity = 1,
    clust_num_ores = 1,
    ore_type = "scatter",
    clust_size = 1,
    ore = "default:diamondblock"
}

core.register_ore(testOre)
local luaOre = core.registered_ores["testore"]
core.clear_registered_ores()


core.native_register_ore(testOre)
local nativeOre = core.registered_ores["testore"]
core.clear_registered_ores()

--test register_schematic

local testSchem = {
    name = "testSchem",
	size = {x = 3, y = 3, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "default:bush_leaves"}, {name = "default:bush_leaves"}, {name = "default:bush_leaves"}, -- lower layer
		{name = "default:bush_leaves"}, {name = "default:bush_leaves"}, {name = "default:bush_leaves"}, -- middle layer
		{name = "air"}, {name = "air"}, {name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "default:bush_leaves"}, {name = "default:bush_stem"}, {name = "default:bush_leaves"}, -- lower layer
		{name = "default:bush_leaves"}, {name = "default:bush_leaves"}, {name = "default:bush_leaves"}, -- middle layer
		{name = "air"}, {name = "default:bush_leaves"}, {name = "air"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "default:bush_leaves"}, {name = "default:bush_leaves"}, {name = "default:bush_leaves"}, -- lower layer
		{name = "default:bush_leaves"}, {name = "default:bush_leaves"}, {name = "default:bush_leaves"}, -- middle layer
		{name = "air"}, {name = "air"}, {name = "air"}, -- top layer
	}
}

--issue: registered schematics table is not available at init time?
local luaSchematic
core.register_schematic(testSchem)
--luaSchematic = minetest.registered_schematics["testSchem"]
core.clear_registered_schematics()

local nativeSchematic
core.register_schematic(testSchem)
--nativeSchematic = minetest.registered_schematics["testSchem"]
core.clear_registered_schematics()

--test clear_registered_biomes
core.clear_registered_biomes()

core.register_biome(testBiome)
core.clear_registered_biomes()
local luaBiomeCleared = (core.registered_biomes["testbiome"] == nil)

core.register_biome(testBiome)
core.native_clear_registered_biomes()
local nativeBiomeCleared = (core.registered_biomes["testbiome"] == nil)

local testBiomeCleared = (luaBiomeCleared and nativeBiomeCleared)

--test clear_registered_decorations
core.clear_registered_decorations()

luaHandle = core.register_decoration(testDeco)
core.clear_registered_decorations()
local luaDecoCleared = (core.registered_decorations[luaHandle] == nil)

nativeHandle = core.register_decoration(testDeco)
core.native_clear_registered_decorations()
local nativeDecoCleared = (core.registered_decorations[nativeHandle] == nil)

local testDecoCleared = (luaDecoCleared and nativeDecoCleared)

core.clear_registered_decorations()

--test clear_registered_ores
core.clear_registered_ores()

core.register_ore(testOre)
core.clear_registered_ores()
local luaOreCleared = (core.registered_ores["testore"] == nil)

nativeHandle = core.register_ore(testOre)
core.native_clear_registered_ores()
local nativeOreCleared = (core.registered_ores["testore"] == nil)

local testOreCleared = (luaOreCleared and nativeOreCleared)

core.clear_registered_ores();

--test generate_ores
--function simply checks if both functions generate ores because generation is not deterministic
local luaOres = false
local nativeOres = false
local tested = false
core.register_ore(testOre)

--sets entire map to a block for testing (except for air blocks)
SetMap = function (blockname, vmanip)
    local blocks = vmanip:get_data()
    local blockId = core.get_content_id(blockname)
    local airId = core.get_content_id("air")
    for i, v in pairs(blocks) do
        if v ~= airId then blocks[i] = blockId end
    end
    vmanip:set_data(blocks)
    vmanip:write_to_map()
end

core.register_on_generated(
    function (minp, maxp, blockseed)
        if not tested then 
            local vmanip = core.get_mapgen_object("voxelmanip")
            local testId = core.get_content_id("default:diamondblock")
            SetMap("default:stone", vmanip)
            core.generate_ores(vmanip, minp, maxp)
            local currData = vmanip:get_data()
            luaOres = TableContains(currData, testId)
            vmanip:write_to_map()

            SetMap("default:stone", vmanip)
            --core.native_generate_ores(vmanip, minp, maxp)
            currData = vmanip:get_data()
            nativeOres = TableContains(currData, testId)
            vmanip:write_to_map()
            SetMap("default:stone", vmanip)
            tested = true
        end
    end
)

--test generate_decorations
local luaDecos = false
local nativeDecos = false
local tested = false

core.register_decoration(testDeco)

--helper function that resets a node to air (assumes that decoration is a node)
SetNodeToAir = function(nodename, vmanip)
    local nodeId = core.get_content_id(nodename)
    local airId = core.get_content_id("air")
    local blocks = vmanip:get_data()
    for i, v in pairs(blocks) do 
        if v == nodeId then blocks[i] = airId end
    end
    vmanip:set_data(blocks)
    vmanip:write_to_map()
end

core.register_on_generated(
    function(minp, maxp, blockseed)
            if not tested then 
            local vmanip = core.get_mapgen_object("voxelmanip")
            local testId = core.get_content_id("default:goldblock")

            core.generate_decorations(vmanip, minp, maxp)
            vmanip:write_to_map()
            if TableContains(vmanip:get_data(), testId) then luaDecos = true end
            SetNodeToAir("default:goldblock", vmanip)

            --core.native_generate_decorations(vmanip, minp, maxp)
            vmanip:write_to_map()
            if TableContains(vmanip:get_data(), testId) then nativeDecos = true end
            SetNodeToAir("default:goldblock", vmanip)
            tested = true
        end
    end
)

--test create_schematic
local tested = false
core.register_on_generated(
    function(minp, maxp, blockseed)
        if not tested then
        core.create_schematic(minp, maxp, {}, "luaschem.mts", {})
        core.native_create_schematic(minp, maxp, {}, "nativeschem.mts", {})
        tested = true
        end
    end
)
--cleans files up
core.register_on_shutdown(
    function()
        os.remove("luaschem.mts")
        os.remove("nativeschem.mts")
    end
)
--helper function to retrieve biomes
core.register_chatcommand("get_biomes",
{
    description="Helper command - writes all registered biomes to file",
    func = function(self)
        local f = io.open("biomes.txt", "w")
        f:write(dump(core.registered_biomes))
        return true
    end
})
--helper function to retrieve ores
core.register_chatcommand("get_ores",
{
    description="Helper command - writes all registered ores to file",
    func = function(self)
        local f = io.open("ores.txt", "w")
        f:write(dump(core.registered_ores))
        return true
    end
})

--helper function to retrieve nodes
core.register_chatcommand("get_nodes",
{
    description="Helper command - writes all registered nodes to file",
    func = function(self)
        local f = io.open("nodes.txt", "w")
        f:write(dump(core.registered_ores))
        return true
    end
})

--normal test commands
core.register_chatcommand("lua_get_biome_data", 
{
    description = "Invokes lua_api > l_get_biome_data",
    func = function (self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.get_biome_data(pos)
        if biomeData then return true, "Biome data returned: "..dump(biomeData)
        else return false, "Biome data returned nil" end
    end
})

core.register_chatcommand("native_get_biome_data", 
{
    description = "Invokes lua_api > l_native_get_biome_data",
    func = function (self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.native_get_biome_data(pos)
        if biomeData then return true, "Biome data returned: "..dump(biomeData)
        else return false, "Biome data returned nil" end
    end
})

core.register_chatcommand("test_get_biome_data", 
{
    description = "Compares output of lua and native get_biome_data",
    func = function (self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.get_biome_data(pos)
        local nativeData = core.native_get_biome_data(pos)
        if dump(biomeData) == dump(nativeData) then return true, "Biome data and native biome data are the same"
        else return false, "Biome Data not the same"..dump(nativeData)..dump(biomeData) end
    end
})

core.register_chatcommand("lua_get_biome_id", 
{
    description = "Invokes lua_api > l_get_biome_id",
    func = function (self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.native_get_biome_data(pos)
        local biomeName = core.get_biome_name(biomeData["biome"])
        local biomeId = core.get_biome_id(biomeName)
        if biomeId then return true, "BiomeId: "..tostring(biomeId)
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("lua_get_native_biome_id",
{
    description = "Invokes lua_api > l_native_get_biome_id",
    func = function (self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.native_get_biome_data(pos)
        local biomeName = core.get_biome_name(biomeData["biome"])
        local biomeId = core.native_get_biome_id(biomeName)
        if biomeId then return true, "BiomeId: "..tostring(biomeId)
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("test_get_biome_id", 
{
    description = "Compares output of lua and native get_biome_id",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.native_get_biome_data(pos)
        local biomeName = core.get_biome_name(biomeData["biome"])
        local biomeId = core.get_biome_id(biomeName)
        local nativeId = core.native_get_biome_id(biomeName)
        if tostring(biomeId) == tostring(nativeId) then return true, "Success, function output is the same"
        else return false, "Biome Ids are different - Native Id: "..tostring(nativeId).." Lua Id: "..tostring(BiomeId) end
    end
})

core.register_chatcommand("lua_get_biome_name", {
    description = "Invokes lua_api > get_biome_name",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.get_biome_data(pos)
        local biomeName = core.get_biome_name(biomeData["biome"])    
        return true, "Biome name: "..tostring(biomeName)
    end
})

core.register_chatcommand("native_get_biome_name", {
    description = "Invokes lua_api > native_get_biome_name",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.get_biome_data(pos)
        local biomeName = core.native_get_biome_name(biomeData["biome"])    
        return true, "Biome name: "..tostring(biomeName)
    end
})

core.register_chatcommand("test_native_get_biome_name", {
    description = "Compares output of lua and native get_biome_name",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local biomeData = core.get_biome_data(pos)
        local biomeName = core.get_biome_name(biomeData["biome"])
        local nativeName = core.native_get_biome_name(biomeData["biome"])
        if biomeName == nativeName then return true, "Lua and native biome names are the same"
        else return false, "Biome and native names are not the same" end
    end
})

core.register_chatcommand("lua_get_heat", {
    description = "Invokes lua_api > get_heat",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local heat = core.get_heat(pos)
        if heat then return true, "Heat: "..tostring(heat)
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("native_get_heat", {
    description = "Invokes lua_api > native_get_heat",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local heat = core.native_get_heat(pos)
        if heat then return true, "Heat: "..tostring(heat)
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("test_get_heat", {
    description = "Compares output of lua and native get_heat",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local heat = core.get_heat(pos)
        local nativeHeat = core.native_get_heat(pos)
        if heat == nativeHeat then return true, "Lua and native heats are the same"
        else return false, "Lua and native heats are not the same" end
    end
})

core.register_chatcommand("lua_get_humidity", {
    description = "Invokes lua_api > get_humidity",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local hum = core.get_humidity(pos)
        if hum then return true, "Humidity: "..hum
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("native_get_humidity", {
    description = "Invokes lua_api > native_get_humidity",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local hum = core.native_get_humidity(pos)
        if hum then return true, "Humidity: "..hum
        else return false, "function returned nil" end
    end
})

core.register_chatcommand("test_get_humidity", {
    description = "Compares lua and native get_humidity",
    func = function(self)
        local player = core.get_player_by_name("singleplayer")
        local pos = player:get_pos()
        local nativeHum = core.native_get_humidity(pos)
        local hum = core.get_humidity(pos)
        if hum == nativeHum then return true, "Lua and native humidities are the same"
        else return false, "Lua and native humidities are not the same" end
    end
})

core.register_chatcommand("lua_get_mapgen_object", 
{
    description = "Invokes lua_api > get_mapgen_object",
    func = function (self)
        if MapgenObj then return true, "Mapgen Object: "..dump(MapgenObj)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_mapgen_object", 
{
    description = "Invokes lua_api > native_get_mapgen_object",
    func = function (self)
        if NativeMapgenObj then return true, "Mapgen Object: "..dump(NativeMapgenObj)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_mapgen_object", 
{
    description = "Compares output of lua and native get_mapgen_object",
    func = function (self)
        if dump(MapgenObj) == dump(NativeMapgenObj) then return true, "Mapgen objects are identical"
        else return false, "Mapgen objects are different"..dump(MapgenObj)..dump(NativeMapgenObj) end
    end
})

core.register_chatcommand("lua_get_spawn_level", 
{
    description = "Invokes lua_api > get_spawn_level",
    func = function ()
        local player = core.get_player_by_name("singleplayer")
        --teleport to known appropriate spawn location
        player:set_pos({x=0, y=10.5, z=-192.0})
        local pos = player:get_pos()
        local spawnLvl = core.get_spawn_level(pos["y"], pos["z"])
        if spawnLvl then return true, "spawn result: "..dump(spawnLvl)
        else return false, "spawn level is nil at"..dump(pos) end 
    end
})

core.register_chatcommand("native_get_spawn_level", 
{
    description = "Invokes lua_api > native_get_spawn_level",
    func = function ()
        local player = core.get_player_by_name("singleplayer")
        player:set_pos({x=0, y=10.5, z=-192.0})
        local pos = player:get_pos()
        local spawnLvl = core.native_get_spawn_level(pos["y"], pos["z"])
        if spawnLvl then return true, "spawn level: "..dump(spawnLvl) end
    end
})

core.register_chatcommand("test_native_get_spawn_level", 
{
    description = "Compares output of lua and native get_spawn_level",
    func = function ()
        local player = core.get_player_by_name("singleplayer")
        player:set_pos({x=0, y=10.5, z=-192.0})
        local pos = player:get_pos()
        local nativeSpawnLvl = core.native_get_spawn_level(pos["y"], pos["z"])
        local spawnLvl = core.get_spawn_level(pos["y"], pos["z"])
        if spawnLvl == nativeSpawnLvl then return true, "spawn levels are the same" 
        else return false, "spawn levels are different" end
    end
})

core.register_chatcommand("lua_get_mapgen_params",
{
    description="Invokes lua_api > get_mapgen_params",
    func=function()
        local mapgenParams = core.get_mapgen_params()
        if mapgenParams then return true, "Mapgen params: "..dump(mapgenParams)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_mapgen_params",
{
    description="Invokes lua_api > get_native_mapgen_params",
    func=function()
        local nativeParams = core.native_get_mapgen_params()
        if nativeParams then return true, "Native mapgen params: "..dump(nativeParams)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_native_mapgen_params",
{
    description="Compares lua and native get_mapgen_params",
    func=function()
        local nativeParams = core.native_get_mapgen_params()
        local mapgenParams = core.get_mapgen_params()
        if dump(mapgenParams) == dump(nativeParams) then return true, "Native and Lua function outputs identical"
        else return false, "Native and Lua function outputs different" end
    end
})

core.register_chatcommand("lua_set_mapgen_params", {
    description="Invokes lua_api > set_mapgen_params",
    func=function ()
    if luaChanged_params then return true, "Mapgen params set with lua_api"
    else return false, "Mapgen params not set with lua_api" end
    end
})

core.register_chatcommand("native_set_mapgen_params", {
    description="Invokes lua_api > set_mapgen_params",
    func=function ()
        if nativeChanged_params then return true, "Mapgen params set with native_api"
        else return false, "Mapgen params not set with native_api" end
    end
})

core.register_chatcommand("test_set_mapgen_params", {
    description="Checks that both set_mapgen_params are the same",
    func = function()
    if sameValue_params then return true, "Lua and native functions set mapgen params to same value"
    else return false, "Lua and native functions did not set mapgen params to same value" end
    end
})
--must pass in name of field of current mapgen that you want
core.register_chatcommand("lua_get_mapgen_setting", {
    description="Invokes lua_api > get_mapgen_setting",
    func = function(self)
        local failedRetrieval = false
        local setting
        setting = core.get_mapgen_setting("mg_name")
        failedRetrieval = (setting == nil)  
        setting = core.get_mapgen_setting("seed")
        failedRetrieval = (setting == nil)
        setting = core.get_mapgen_setting("chunksize")
        failedRetrieval = (setting == nil)
        setting = core.get_mapgen_setting("water_level")
        failedRetrieval = (setting == nil)
        setting = core.get_mapgen_setting("mg_flags")
        failedRetrieval = (setting == nil)
        
        if failedRetrieval == false then return true, "All calls returned values"
        else return false, "Function returned nil at least once" end
    end
})

core.register_chatcommand("native_get_mapgen_setting", {
    description="Invokes lua_api > native_get_mapgen_setting",
    func = function(self)
        local failedRetrieval = false
        local setting
        setting = core.native_get_mapgen_setting("mg_name")
        failedRetrieval = (setting == nil)  
        setting = core.native_get_mapgen_setting("seed")
        failedRetrieval = (setting == nil)
        setting = core.native_get_mapgen_setting("chunksize")
        failedRetrieval = (setting == nil)
        setting = core.native_get_mapgen_setting("water_level")
        failedRetrieval = (setting == nil)
        setting = core.native_get_mapgen_setting("mg_flags")
        failedRetrieval = (setting == nil)
        
        if failedRetrieval == false then return true, "All calls returned values"
        else return false, "Function returned nil at least once" end
    end
})

core.register_chatcommand("test_get_mapgen_setting", {
    description="Compares output of lua and native get_mapgen_setting",
    func = function(self)
        local setting = {
            ["mg_name"] = core.get_mapgen_setting("mg_name"),
            ["seed"] = core.get_mapgen_setting("seed"),
            ["chunksize"] = core.get_mapgen_setting("chunksize"),
            ["water_level"] = core.get_mapgen_setting("water_level"),
            ["mg_flags"] = core.get_mapgen_setting("mg_flags")
        }
        local nativeSetting = {
            ["mg_name"] = core.native_get_mapgen_setting("mg_name"),
            ["seed"] = core.native_get_mapgen_setting("seed"),
            ["chunksize"] = core.native_get_mapgen_setting("chunksize"),
            ["water_level"] = core.native_get_mapgen_setting("water_level"),
            ["mg_flags"] = core.native_get_mapgen_setting("mg_flags")            
        }

        if dump(setting) == dump(nativeSetting) then return true, "Mapgen settings identical"
        else return false, "Setting: "..dump(setting).."Native setting: "..dump(nativeSetting) end
    end
})

core.register_chatcommand("lua_get_mapgen_setting_noiseparams", {
    description="Invokes lua_api > lua_get_mapgen_setting_noiseparams",
    func = function(self)
        local setting
        setting = core.get_mapgen_setting_noiseparams("water_level")
        if setting then return true, "Setting noiseparams: "..dump(setting)
        else return false, "Function call returned nil" end
    end
})

core.register_chatcommand("native_get_mapgen_setting_noiseparams", {
    description="Invokes lua_api > lua_get_mapgen_setting_noiseparams",
    func = function(self)
        setting = core.native_get_mapgen_setting_noiseparams("water_level")
        if setting then return true, "Setting noiseparams:"..dump(setting)
        else return false, "Function call returned nil" end
    end
})

core.register_chatcommand("test_get_mapgen_setting_noiseparams", {
    description="Compares lua and native get_mapgen_setting_noiseparams",
    func = function(self)
        setting = core.get_mapgen_setting_noiseparams("water_level")
        nativeSetting = core.native_get_mapgen_setting_noiseparams("water_level")
        if dump(setting) == dump(nativeSetting) then return true, "Function outputs identical"
        else return false, "Functions returned different values\n setting: "..dump(setting).."\n native setting: "..dump(setting) end
    end
})

core.register_chatcommand("lua_set_mapgen_setting", {
    description="Invokes lua_api > set_mapgen_setting",
    func=function ()
    if luaChanged_setting then return true, "Mapgen params set with lua_api"
    else return false, "Mapgen params not set with lua_api" end
    end
})

core.register_chatcommand("native_set_mapgen_setting", {
    description="Invokes lua_api > set_mapgen_setting",
    func=function ()
        if nativeChanged_setting then return true, "Mapgen params set with native_api"
        else return false, "Mapgen params not set with native_api" end
    end
})

core.register_chatcommand("test_set_mapgen_setting", {
    description="Checks that both set_mapgen_settings are the same",
    func = function()
    if sameValue_setting then return true, "Lua and native functions set mapgen params to same value"
    else return false, "Lua and native functions did not set mapgen params to same value" end
    end
})

core.register_chatcommand("lua_set_mapgen_setting_noiseparams", {
    description="Invokes lua_api > set_mapgen_setting_noiseparams",
    func=function ()
    if luaChanged_noiseparams then return true, "Mapgen noiseparams set with lua_api"
    else return false, "Setting noiseparams not set with lua_api" end
    end
})

core.register_chatcommand("native_set_mapgen_setting_noiseparams", {
    description="Invokes lua_api > set_mapgen_setting",
    func=function ()
        if nativeChanged_noiseparams then return true, "Mapgen noiseparams set with native_api"
        else return false, "Mapgen noiseparams not set with native_api" end
    end
})

core.register_chatcommand("test_set_mapgen_setting_noiseparams", {
    description="Checks that both set_mapgen_settings are the same",
    func = function()
    if sameValue_noiseparams then return true, "Lua and native functions set noiseparams to same value"
    else return false, "Lua and native functions did not set noiseparams to same value" end
    end
})

core.register_chatcommand("lua_set_noiseparams", {
    description = "Invokes lua_api > set_noiseparams",
    func = function ()
        core.set_noiseparams("water_level", testNoiseparams, false)
        local currNoiseparams = core.get_noiseparams("water_level")
        core.set_noiseparams("water_level", defaultNoiseparams, false)
        if dump(currNoiseparams) ~= dump(core.get_noiseparams("water_level")) then return true, "Noiseparams set with lua_api"
        else return false, "Noiseparams not set with lua_api" end
    end
})

core.register_chatcommand("native_set_noiseparams", {
    description = "Invokes native_api > set_noiseparams",
    func = function ()
        core.native_set_noiseparams("water_level", testNoiseparams, false)
        local currNoiseparams = core.native_get_noiseparams("water_level")
        core.native_set_noiseparams("water_level", defaultNoiseparams, false)
        if dump(currNoiseparams) ~= dump(core.native_get_noiseparams("water_level")) then return true, "Noiseparams set with native_api"
        else return false, "Noiseparams not set with native_api" end
    end
})

core.register_chatcommand("test_set_noiseparams", {
    description = "Compares lua and native set_noiseparams",
    func = function ()
        core.set_noiseparams("water_level", testNoiseparams, false)
        local luaNoiseparams = core.get_noiseparams("water_level")
        core.set_noiseparams("water_level", defaultNoiseparams, false)

        core.native_set_noiseparams("water_level", testNoiseparams, false)
        local nativeNoiseparams = core.native_get_noiseparams("water_level")
        core.native_set_noiseparams("water_level", defaultNoiseparams, false)

        if dump(luaNoiseparams) == dump(nativeNoiseparams) then return true, "Noiseparams set to same value"
        else return false, "Noiseparams not set to same value" end
    end
})

core.register_chatcommand("lua_get_noiseparams", {
    description = "Invokes lua_api > get_noiseparams",
    func = function (self)
        local noiseparams = core.get_noiseparams("water_level")
        if noiseparams then return true, "Noiseparams not nil: "..dump(noiseparams)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_noiseparams", {
    description = "Invokes native_api > get_noiseparams",
    func = function (self)
        local noiseparams = core.native_get_noiseparams("water_level")
        if noiseparams then return true, "Noiseparams not nil: "..dump(noiseparams)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_noiseparams", {
    description = "Compares native and lua get_noiseparams",
    func = function (self)
        local noiseParams = core.get_noiseparams("water_level")
        local nativeNoiseparams = core.native_get_noiseparams("water_level")
        if (dump(noiseParams) == dump(nativeNoiseparams)) then return true, "Functions returned same value"
        else return false, "Functions did not return same value" end
    end
})

core.register_chatcommand("get_decorations",
{
    description="Helper command - prints all registered decorations",
    func = function(self)
        local f = io.open("decorations.txt", "w")
        f:write(dump(core.registered_decorations))
        return true
    end
})

--[[
tested behavior: Always starts with dungeon, temple, decoration by default
subsequent set commands can add flags, but not remove them. Same goes for flags.
]]--
core.register_chatcommand("lua_set_gen_notify", {
    description="Invokes lua_api > set_gen_notify",
    func = function (self)
        --always starts with dungeon, temple, decoration by default
        core.set_gen_notify("dungeon, temple, decoration, cave_begin", {22})
        local luaFlagString, idTable = core.get_gen_notify()
        if string.find(luaFlagString, "cave_begin") and TableContains(idTable, 22) then return true, "Gen notify updated"
        else return false, "Gen notify not updated"..dump(core.get_gen_notify()) end
    end
})

core.register_chatcommand("native_set_gen_notify", {
    description="Invokes native_api > set_gen_notify",
    func = function (self)
        core.set_gen_notify("dungeon, temple, decoration, cave_begin, cave_end", {9})
        local flagString, idTable = core.get_gen_notify()
        if string.find(flagString, "cave_end") and TableContains(idTable, 9) then return true, "Gen notify updated"
        else return false, "Did not set gen notify table"..dump(core.get_gen_notify()) end
    end
})

--just checks that both things were added because no way to reset table during runtime
core.register_chatcommand("test_set_gen_notify", {
    description="Compares lua and native API set_gen_notify output",
    func = function (self)
        local flagString, idTable = core.get_gen_notify()
        if string.find(flagString, "cave_begin") and string.find(flagString, "cave_end") and TableContains(idTable, 22) and TableContains(idTable, 9) then 
        return true, "Native and Lua functions modified gen notify successfully" else return false, "At least one function did not modify gen notify successfully"..dump(core.get_gen_notify()) end
    end
})

core.register_chatcommand("lua_get_gen_notify", 
{
    description="Invokes lua_api > get_gen_notify",
    func = function(self)
        local genNotify = core.get_gen_notify()
        if genNotify then return true, "gen_notify table: "..dump(genNotify)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_gen_notify", 
{
    description="Invokes native_api > get_gen_notify",
    func = function(self)
        local genNotify = core.native_get_gen_notify()
        if genNotify then return true, "gen_notify table: "..dump(genNotify)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_gen_notify", 
{
    description="Compares core and native get_gen_notify",
    func = function(self)
        local genNotify = core.get_gen_notify()
        local nativeGenNotify = core.native_get_gen_notify()
        if (dump(genNotify) == dump(nativeGenNotify)) then return true, "Lua and native function output identical"
        else return false, "Lua and native function outputs different"..dump(genNotify)..dump(nativeGenNotify) end
    end
})

core.register_chatcommand("lua_get_decoration_id", 
{
    description="Invokes lua_api > get_decoration_id",
    func = function ()
        local id = core.get_decoration_id("default:pine_log")
        if id then return true, "Decoration id: "..id 
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_decoration_id", 
{
    description="Invokes native_api > get_decoration_id",
    func = function ()
        local id = core.native_get_decoration_id("default:pine_log")
        if id then return true, "Decoration id: "..id 
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_decoration_id", 
{
    description="Compares Lua and native get_decoration_id",
    func = function ()
        local id = core.native_get_decoration_id("default:pine_log")
        local nativeId = core.native_get_decoration_id("default:pine_log")
        if id == nativeId then return true, "Function outputs were identical. Id: "..id
        else return false, "Function outputs were different \n id: "..id.."\n native id: "..nativeId end
    end
})

core.register_chatcommand("lua_register_biome", 
{
    description="Invokes lua_api > register_biome",
    func = function(self)
        if luaRegisteredBiome then return true, "Biome was registered"..dump(luaRegisteredBiome)
        else return false, "Biome not registered" end
    end
})

core.register_chatcommand("native_register_biome", 
{
    description="Invokes native_api > register_biome",
    func = function(self)
        if nativeRegisteredBiome then return true, "Biome was registered"..dump(nativeRegisteredBiome)
        else return false, "Biome not registered" end
    end
})

core.register_chatcommand("test_register_biome", 
{
    description="Tests output of Lua and native APIs",
    func = function(self)
        if dump(luaRegisteredBiome) == dump(nativeRegisteredBiome) and luaRegisteredBiome ~= nil then return true, "Registered biomes are identical"
        else return false, "Registered biomes are not identical"..dump(luaRegisteredBiome)..dump(nativeRegisteredBiome) end
    end
})

core.register_chatcommand("lua_register_decoration", 
{
    description = "Invokes lua_api > register_decoration",
    func = function(self)
        if luaDeco then return true, "Lua decoration registered"..dump(luaDeco)
        else return false, "Lua decoration not registered" end
    end
})

core.register_chatcommand("native_register_decoration", 
{
    description = "Invokes native_api > register_decoration",
    func = function(self)
        if nativeDeco then return true, "Native decoration registered"..dump(nativeDeco)
        else return false, "Native decoration not registered" end
    end
})

core.register_chatcommand("test_register_decoration",
{
    description = "Compares output of Lua and native register_decoration",
    func = function (self)
        if dump(luaDeco) == dump(nativeDeco) and luaDeco ~= nil then return true, "Lua and native decos identical"
        else return false, "Lua and native decos different"..dump(luaDeco)..dump(nativeDeco) end
    end
})

core.register_chatcommand("lua_register_ore", 
{
    description = "Invokes lua_api > register_ore",
    func = function(self)
        if luaOre then return true, "Lua ore registered"..dump(luaOre)
        else return false, "Lua ore not registered" end
    end
})


core.register_chatcommand("native_register_ore", 
{
    description = "Invokes native_api > register_ore",
    func = function(self)
        if nativeOre then return true, "Native ore registered"..dump(nativeOre)
        else return false, "Native ore not registered" end
    end
})

core.register_chatcommand("test_register_ore",
{
    description = "Compares output of lua and native registered ores",
    func = function (self)
        if dump(luaOre) == dump(nativeOre) and luaOre ~= nil then return true, "Lua and native ores identical"
        else return false, "Lua and native ores different"..dump(luaOre)..dump(nativeOre) end
    end
})


core.register_chatcommand("lua_register_schematic", 
{
    description = "Invokes lua_api > register_schematic",
    func = function(self)
        if luaSchematic then return true, "Lua schematic registered"..dump(luaSchematic)
        else return false, "Lua schematic not registered" end
    end
})


core.register_chatcommand("native_register_schematic", 
{
    description = "Invokes native_api > register_ore",
    func = function(self)
        if nativeSchematic then return true, "Native ore registered"..dump(nativeSchematic)
        else return false, "Native ore not registered" end
    end
})

core.register_chatcommand("test_register_schematic",
{
    description = "Compares output of lua and native registered ores",
    func = function (self)
        if dump(luaSchematic) == dump(nativeSchematic) and luaSchematic ~= nil then return true, "Lua and native ores identical"
        else return false, "Lua and native ores different"..dump(luaSchematic)..dump(nativeSchematic) end
    end
})

core.register_chatcommand("lua_clear_registered_biomes", 
{
    description = "Invokes lua_api > clear_registered_biomes",
    func = function(self)
        if luaBiomeCleared then return true, "Lua function clears biome"
        else return false, "Lua function did not clear biome" end
    end
})

core.register_chatcommand("native_clear_registered_biomes", 
{
    description = "Invokes native_api > clear_registered_biomes",
    func = function(self)
        if nativeBiomeCleared then return true, "Native function clears biome"
        else return false, "Native function did not clear biome" end
    end
})

core.register_chatcommand("test_clear_registered_biomes", 
{
    description = "Tests both lua and native functions",
    func = function (self)
        if testBiomeCleared then return true, "Both registered biomes cleared"
        else return false, "One or more registered biomes did not clear \n lua: "..tostring(luaBiomeCleared).."\n native: "..tostring(nativeBiomeCleared) end  
    end
})

core.register_chatcommand("lua_clear_registered_decorations", 
{
    description = "Invokes lua_api > clear_registered_decorations",
    func = function(self)
        if luaDecoCleared then return true, "Lua function clears decorations"
        else return false, "Lua function did not clear decorations" end
    end
})

core.register_chatcommand("native_clear_registered_decorations", 
{
    description = "Invokes native_api > clear_registered_decorations",
    func = function(self)
        if nativeDecoCleared then return true, "Native function clears decorations"
        else return false, "Native function did not clear decorations" end
    end
})

core.register_chatcommand("test_clear_registered_decorations", 
{
    description = "Tests both lua and native functions",
    func = function (self)
        if testDecoCleared then return true, "Both registered decorations cleared"
        else return false, "One or more registered decorations did not clear \n lua: "..tostring(luaDecoCleared).."\n native: "..tostring(nativeDecoCleared) end
    end
})


core.register_chatcommand("lua_clear_registered_ores", 
{
    description = "Invokes lua_api > clear_registered_ores",
    func = function(self)
        if luaOreCleared then return true, "Lua function clears ores"
        else return false, "Lua function did not clear ores" end
    end
})

core.register_chatcommand("native_clear_registered_ores", 
{
    description = "Invokes native_api > clear_registered_ores",
    func = function(self)
        if nativeOreCleared then return true, "Native function clears ores"
        else return false, "Native function did not clear ores" end
    end
})

core.register_chatcommand("test_clear_registered_ores", 
{
    description = "Tests both lua and native functions",
    func = function (self)
        if testOreCleared then return true, "Both registered ores cleared"
        else return false, "One or more registered ores did not clear \n lua: "..tostring(luaOreCleared).."\n native: "..tostring(nativeOreCleared) end
    end
})

core.register_chatcommand("lua_clear_registered_schematics", 
{
    description = "Invokes lua_api > clear_registered_schematics",
    func = function(self)
        if luaOreCleared then return true, "Lua function clears schematics"
        else return false, "Lua function did not clear schematics" end
    end
})

core.register_chatcommand("native_clear_registered_schematics", 
{
    description = "Invokes native_api > clear_registered_schematics",
    func = function(self)
        if nativeOreCleared then return true, "Native function clears schematics"
        else return false, "Native function did not clear schematics" end
    end
})

core.register_chatcommand("test_clear_registered_schematics", 
{
    description = "Tests both lua and native functions",
    func = function (self)
        if testOreCleared then return true, "Both registered schematics cleared"
        else return false, "One or more registered schematics did not clear \n lua: "..tostring(luaOreCleared).."\n native: "..tostring(nativeOreCleared) end
    end
})

core.register_chatcommand("lua_generate_ores", {
    description="Invokes lua_api > generate_ores",
    func = function (self)
        local id = core.get_content_id("default:diamondblock")
        if luaOres then return true, "Lua ores generated"
        else return false, "Lua ores not generated" end
    end
})

core.register_chatcommand("native_generate_ores", {
    description="Invokes native_api > generate_ores",
    func = function (self)
        if nativeOres then return true, "Native ores generated \n"
        else return false, "Native ores not generated" end
    end
})

core.register_chatcommand("test_generate_ores", {
    description="Compares output of lua and native generated ores",
    func = function (self)
        if luaOres == true and nativeOres == true then return true, "Lua and native ores are the same"
        else return false, "Lua and native ores are not the same" end
    end
})

core.register_chatcommand("lua_generate_decorations", {
    description="Invokes lua_api > generate_decorations",
    func = function (self)
        if luaDecos then return true, "Lua decorations generated \n"
        else return false, "Lua decorations not generated" end
    end
})

core.register_chatcommand("native_generate_decorations", {
    description="Invokes native_api > generate_decorations",
    func = function (self)
        if nativeDecos then return true, "Native decorations generated \n"
        else return false, "Native decorations not generated" end
    end
})

core.register_chatcommand("test_generate_decorations", {
    description="Compares output of lua and native generated decorations",
    func = function (self)
        if luaDecos == true and nativeDecos == true then return true, "Lua and native decorations are the same"
        else return false, "Lua and native ores are not the same" end
    end
})

core.register_chatcommand("lua_create_schematic", {
    description="Invokes lua_api > create_schematic",
    func = function (self)
        local f = io.open("luaschem.mts", "r")
        if f ~= nil then 
        return true, "Lua schematic file generated" 
        else return false, "Lua schematic not generated" end
    end
})

core.register_chatcommand("native_create_schematic", {
    description="Invokes native_api > create_schematic",
    func = function (self)
        local f = io.open("nativeschem.mts", "r") 
        if f ~= nil then return true, "Native schematic file generated"
        else return false, "Native schematic not generated" end
    end
})

core.register_chatcommand("test_create_schematic", {
    description="Compares generated schematic files for lua and native APIs",
    func = function (self)
        local luaFile = io.open("luaschem.mts", "r")
        local luaData = luaFile:read("*all")
        local nativeFile = io.open("nativeschem.mts", "r")
        local nativeData = nativeFile:read("*all")
        if dump(luaData) == dump(nativeData) then return true, "Lua and native generated schematic files are identical"
        else return false, "Lua and native schematic files are not identical" end
    end
})

core.register_chatcommand("lua_serialize_schematic", {
    description="Invokes lua_api > serialize_schematic",
    func = function (self)
        local luamts = core.serialize_schematic(testSchem, "mts", {})
        local luaLua = core.serialize_schematic(testSchem, "lua", {})
        if luamts ~= nil and luaLua ~= nil then return true, "Schematics serialized".." fmts: "..tostring(luamts).." lua: "..luaLua
        else return false, "One or more schematics not serialized - ".."fmts: "..tostring(luamts).." lua: "..tostring(luaLua) end
    end
})
--[[ Confirmed working in debugger, check Lua code ]]--
core.register_chatcommand("native_serialize_schematic", {
    description="Invokes native_api > serialize_schematic",
    func = function (self)
        local nativemts = core.native_serialize_schematic(testSchem, "mts", {})
        local nativeLua = core.native_serialize_schematic(testSchem, "lua", {})
        if nativemts ~= nil and nativeLua ~= nil then return true, "Schematics serialized".." fmts: "..tostring(nativemts).." lua: "..tostring(nativeLua)
        else return false, "One or more schematics not serialized - ".."fmts: "..tostring(nativemts).." lua: "..tostring(nativeLua) end
    end
})

core.register_chatcommand("test_serialize_schematic", {
    description="Compares serialized versions of lua and native APIs",
    func = function (self)
        local errorstring = ""
        local luaMts = core.serialize_schematic(testSchem, "mts", {})
        local luaLua = core.serialize_schematic(testSchem, "lua", {})
        local nativeMts = core.native_serialize_schematic(testSchem, "mts", {})
        local nativeLua = core.native_serialize_schematic(testSchem, "lua", {})

        local mtsIdentical = (luaMts == nativeMts)
        if mtsIdentical == false then errorstring = errorstring.."Lua and native mts data were not identical - ".."lua: "..luaMts.." native: "..nativeMts.."\n" end
        
        local luaIdentical = (luaLua == nativeLua)
        if luaIdentical == false then errorstring = errorstring.."Lua and native lua data were not identical - ".."lua: "..luaLua.." native: "..nativeLua end

        if errorstring == "" then return true, "Lua and native serialized schematics were identical"
        else return false, errorstring end
    end
})

--both lua and nil read as nil for some reason
core.register_chatcommand("lua_read_schematic", {
    description="Invokes lua_api > read_schematic",
    func = function (self)
        local schem = core.read_schematic(testSchem, {})
        if schem ~= nil then return true, "Schematic read correctly"
        else return false, "Lua function returned nil" end
    end
})
core.register_chatcommand("native_read_schematic", {
    description="Invokes native_api > read_schematic",
    func = function (self)
        local schem = core.native_read_schematic(testSchem, {})
        if schem ~= nil then return true, "Schematic read correctly"
        else return false, "Native function returned nil" end
    end
})

core.register_chatcommand("test_read_schematic", {
    description="Tests output of Lua and native read_schematic",
    func = function (self)
        local luaSchem = core.read_schematic("luaschem.mts", {})
        local nativeSchem = core.native_read_schematic("luaschem.mts", {})
        if luaSchem ~= nil and dump(luaSchem) == dump(testSchem) then return true, "Lua and native schematics identical"
        else return false, "Lua schematic:\n"..dump(luaSchem).."Native schematic: "..dump(nativeSchem) end
    end
})