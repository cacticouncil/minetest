local playerName = "singleplayer"
core.register_on_joinplayer(function(player)
    playerName = player:get_player_name()
end)

local modpath = core.get_modpath("testingnativeapi_server")
InitEnvVars = assert(loadfile(modpath.."/env.lua", "t"))
InitEnvVars()

local rightClicked = false
local punched = false
core.register_entity("testingnativeapi_server:testentity", 
{
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-1, -1, -1, 1, 1, 1},
        visual = "mesh",
        visual_size = {x = 10, y = 10},
        mesh="animalia_reindeer.b3d",
        textures={"animalia_reindeer.png"},
        spritediv = {x = 10, y = 10},
        initial_sprite_basepos = {x = 0, y = 0},
    },
    get_type=function ()
        return "player"
    end,
    on_rightclick = function(self, clicker)
        rightClicked = true
    end,
    on_punch=function (self, puncher, time_fron_last_punch, tool_capabilities)
        punched = true
    end
})

--helper function that spawns test entity at player's position for debugging
core.register_chatcommand("test_spawn", {
    description="Spawns a test entity at player's position",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        return true, "Test entity spawned at: "..dump(entity:get_pos())
    end
})
core.register_chatcommand("lua_remove", {
    description="Invokes lua_api > remove",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        entity:remove()
        if entity:get_pos() == nil then return true, "Entity successfully removed"
        else return false, "Entity not removed, punch to remove it" end
    end
})

core.register_chatcommand("native_remove", {
    description="Invokes native_api > remove",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        entity:native_remove()
        if entity:get_pos() == nil then return true, "Entity successfully removed"
        else return false, "Entity not removed, punch to remove it" end    
    end

})

core.register_chatcommand("test_remove", {
    description="Invokes both lua and native remove functions",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local luaRemoved, nativeRemoved = false, false

        local luaEntity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        luaEntity:remove()
        if luaEntity:get_pos() == nil then luaRemoved = true end
        
        local nativeEntity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        nativeEntity:native_remove()
        if nativeEntity:get_pos() == nil then nativeRemoved = true end
        
        if luaRemoved and nativeRemoved then return true, "Lua and native entities removed"
        else return false, "Lua entity removed: "..luaRemoved.." Native entity removed: "..nativeRemoved end
    end
})

core.register_chatcommand("lua_get_pos", {
    description="Invokes lua_api > get_pos", 
    func = function ()
        local player = core.get_player_by_name(playerName)
        local pos = player:get_pos()
        if pos then return true, "Player position returned"
        else return false, "Player position not returned" end
    end
})

core.register_chatcommand("native_get_pos", {
    description="Invokes native_api > get_pos", 
    func = function ()
        local player = core.get_player_by_name(playerName)
        local pos = player:native_get_pos()
        if pos then return true, "Player position returned"
        else return false, "Player position not returned" end
    end
})

core.register_chatcommand("test_get_pos", {
    description="Compares output of native and Lua get_pos APIs",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local luaPos = player:get_pos()
        local nativePos = player:native_get_pos()
        if luaPos ~= nil and dump(luaPos) == dump(nativePos) then return true, "Lua and native positions are the same"
        else return false, "Lua pos: "..dump(luaPos).." Native pos: "..dump(nativePos) end
    end
})

core.register_chatcommand("lua_set_pos", {
    description="Invokes lua_api > set_pos",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()
        player:set_pos({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1})
        local luaPos = player:get_pos()
        player:set_pos(initPos)
        if dump(initPos) ~= dump(luaPos) then return true, "Player position adjusted"
        else return false, "Player position not adjusted" end
    end
})

core.register_chatcommand("native_set_pos", {
    description="Invokes native_api > set_pos",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()
        player:native_set_pos({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1})
        local nativePos = player:get_pos()
        player:native_set_pos(initPos)
        if dump(initPos) ~= dump(nativePos) then return true, "Player position adjusted"
        else return false, "Player position not adjusted" end
    end
})

core.register_chatcommand("test_set_pos", {
    description="Invokes both Lua and native set_pos and compares outputs",
    func= function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()

        player:set_pos({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1})
        local luaPos = player:get_pos()
        player:set_pos(initPos)

        player:native_set_pos({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1})
        local nativePos = player:get_pos()
        player:native_set_pos(initPos)

        if dump(luaPos) == dump(nativePos) then return true, "Lua and native functions set position to same value"
        else return false, dump(luaPos)..dump(nativePos) end
    end
})

core.register_chatcommand("lua_move_to", {
    description="Invokes lua_api > move_to",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()
        player:move_to({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1}, false)
        local luaPos = player:get_pos()
        player:set_pos(initPos)

        if dump(initPos) ~= dump(luaPos) then return true, "Player moved"
        else return false, "Player position not moved" end
    end
})

core.register_chatcommand("native_move_to", {
    description="Invokes native_api > move_to",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()
        player:native_move_to({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1}, false)
        local nativePos = player:get_pos()
        player:set_pos(initPos)

        if dump(initPos) ~= dump(nativePos) then return true, "Player moved"
        else return false, "Player position not moved" end
    end
})

core.register_chatcommand("test_move_to", {
    description="Invokes move_to from native and Lua APIs",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initPos = player:get_pos()

        player:move_to({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1}, false)
        local luaPos = player:get_pos()
        player:set_pos(initPos)

        player:native_move_to({x=initPos["x"]+1, y=initPos["y"]+1, z=initPos["z"]+1}, false)
        local nativePos = player:get_pos()
        player:set_pos(initPos)

        if dump(luaPos) == dump(nativePos) then return true, "Lua and native functions moved player to same position"
        else return false, dump(luaPos)..dump(nativePos) end
    end
})


local test_tool_caps = {
    full_punch_interval = 0.0,
    max_drop_level = 3,
    groupcaps = {
        cracky = {
            times = {[1] = 0.1, [2] = 0.1, [3] = 0.1},
            uses = 0,          
            maxlevel = 3,
        },
        fleshy = {
            times = {[1] = 0.1},
            uses = 0,       
            maxlevel = 3,
        }
    },
    damage_groups = {fleshy = 100},
}

core.register_chatcommand("lua_punch", {
    description="Invokes lua_api > punch",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        punched = false

        entity:punch(player, 0.0, test_tool_caps, nil)
        entity:remove()
        if punched then return true, "Entity was punched"
        else return false, "Entity was not punched" end
    end
})

core.register_chatcommand("native_punch", {
    description="Invokes native_api > punch",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")
        punched = false

        entity:native_punch(player, 0.0, test_tool_caps, nil)
        entity:remove()
        if punched then return true, "Entity was punched"
        else return false, "Entity was not punched" end
    end
})



core.register_chatcommand("test_punch", {
    description="Invokes both Lua and native punch function on test entity",
    func=function () 
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:get_pos(), "testingnativeapi_server:testentity", "")

        punched = false
        entity:punch(player, 0.0, test_tool_caps, nil) 
        local luaPunch = punched

        punched = false
        entity:native_punch(player, 0.0, test_tool_caps, nil)
        local nativePunch = punched

        entity:remove()
        if luaPunch ~= nil and luaPunch == nativePunch then return true, "Lua and native punch functional"
        else return false, "Lua punch: "..luaPunch.." Native punch: "..nativePunch end
    end
})

core.register_chatcommand("lua_right_click", {
    description="Invokes lua_api > right_click",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")

        rightClicked = false
        entity:right_click(player)
        entity:remove()
        if rightClicked then return true, "Entity was right clicked"
        else return false, "Entity was not right clicked" end
    end
})

core.register_chatcommand("native_right_click", {
    description="Invokes native_api > right_click",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")

        rightClicked = false
        entity:native_right_click(player)
        entity:remove()
        if rightClicked then return true, "Entity was right clicked"
        else return false, "Entity was not right clicked" end
    end
})

core.register_chatcommand("test_right_click", {
    description="Invokes right_click with native and Lua APIs",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")

        rightClicked = false
        entity:right_click(player)
        local luaClicked = rightClicked

        rightClicked = false
        entity:native_right_click(player)
        local nativeClicked = rightClicked

        entity:remove()
        if luaClicked ~= nil and luaClicked == nativeClicked then return true, "Entity right clicked by native and Lua functions"
        else return false, "Lua clicked: "..tostring(luaClicked).." Native clicked: "..tostring(nativeClicked) end
    end
})

core.register_chatcommand("lua_get_hp", {
    description="Invokes lua_api > get_hp",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")
        
        local hp = entity:get_hp()

        entity:remove()
        if hp == 1 then return true, "Entity HP successfully retrieved"
        else return false, "Entity HP returned: "..tostring(hp) end
    end
})

core.register_chatcommand("lua_set_hp", {
    description="Invokes lua_api > set_hp",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")
        
        entity:set_hp(3, "reason")
        local hp = entity:get_hp()

        entity:remove()
        if hp == 3 then return true, "HP set correctly"
        else return false, "HP set to: "..tostring(hp) end
    end
})

core.register_chatcommand("native_set_hp", {
    description="Invokes native_api > set_hp",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")
        
        entity:native_set_hp(3, "reason")
        local hp = entity:get_hp()

        entity:remove()
        if hp == 3 then return true, "HP set correctly"
        else return false, "HP set to: "..tostring(hp) end
    end
})

core.register_chatcommand("test_set_hp", {
    description="Compares set_hp output for Lua and native APIs",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")

        entity:set_hp(3)
        local luaHP = entity:get_hp()
        entity:set_hp(1)

        entity:native_set_hp(3)
        local nativeHP = entity:native_get_hp()

        entity:remove()
        if luaHP ~= nil and luaHP == nativeHP then return true, "Lua and native API calls set HP to same value"
        else return false, "Lua API: "..tostring(luaHP).." Native API: "..tostring(nativeHP) end
    end
})

core.register_chatcommand("native_get_hp", {
    description="Invokes native_api > get_hp",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")
        
        local hp = entity:native_get_hp()

        entity:remove()
        if hp == 1 then return true, "Entity HP successfully retrieved"
        else return false, "Entity HP returned: "..tostring(hp) end
    end
})

core.register_chatcommand("test_get_hp", {
    description="Compares get_hp output for Lua and native APIs",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local entity = core.add_entity(player:getpos(), "testingnativeapi_server:testentity", "")

        local luaHP = entity:get_hp()
        local nativeHP = entity:native_get_hp()

        entity:remove()
        if luaHP ~= nil and luaHP == nativeHP then return true, "Lua and native API calls returned same output"
        else return false, "Lua API: "..tostring(luaHP).." Native API: "..tostring(nativeHP) end
    end
})

core.register_chatcommand("lua_get_inventory", {
    description="Invokes lua_api > get_inventory",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local inv = player:get_inventory()

        if inv then return true, "Inventory retrieved successfully"
        else return false, "Function returns nil" end
    end
})

core.register_chatcommand("native_get_inventory", {
    description="Invokes native_api > get_inventory",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local inv = player:native_get_inventory()

        if inv then return true, "Inventory retrieved successfully"
        else return false, "Function returns nil" end
    end
})

core.register_chatcommand("test_get_inventory", {
    description="Compares output of native and Lua APIs for get_inventory",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local luaInv = player:get_inventory()
        local nativeInv = player:native_get_inventory()

        if luaInv ~= nil and dump(luaInv) == dump(nativeInv) then return true, "Native and Lua functions return same value"
        else return false, "Lua inv: "..dump(luaInv).."Native Inv: "..dump(nativeInv) end
    end
})

core.register_chatcommand("lua_get_wield_list",  {
    description="Invokes lua_api > get_wield_list",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local list = player:get_wield_list()

        if list ~= nil then return true, "Wield list returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_wield_list",  {
    description="Invokes native_api > get_wield_list",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local list = player:native_get_wield_list()

        if list ~= nil then return true, "Wield list returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_wield_list", {
    description="Compares output of get_wield_list for Lua and native APIs",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local luaList = player:get_wield_list()
        local nativeList = player:native_get_wield_list()

        if luaList ~= nil and dump(luaList) == dump(nativeList) then return true, "Lua and native lists are the same"
        else return false, "Lua list: "..dump(luaList).."Native list: "..dump(nativeList) end
    end
})

local testItem = "default:sword_diamond"
local noItem = ItemStack(nil)
core.register_chatcommand("lua_get_wield_index", {
    description="Invokes lua_api > get_wield_index",
    func = function ()
        local player = core.get_player_by_name(playerName)
        player:set_wielded_item(testItem)
        local index = player:get_wield_index()
        player:set_wielded_item(noItem)
        if index then return true, "Wield index returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_wield_index", {
    description="Invokes native_api > get_wield_index",
    func = function ()
        local player = core.get_player_by_name(playerName)
        player:set_wielded_item(testItem)
        local index = player:native_get_wield_index()
        player:set_wielded_item(noItem)
        if index then return true, "Wield index returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_wield_index", {
    description="Compares output for both Lua and native get_wield_index functions",
    func=function ()
        local player = core.get_player_by_name(playerName)

        player:set_wielded_item(testItem)
        local luaIndex = player:get_wield_index()
        local nativeIndex = player:native_get_wield_index()
        player:set_wielded_item(noItem)
        
        if luaIndex ~= nil and luaIndex == nativeIndex then return true, "Lua and native indices are the same"
        else return false, "Lua index: "..tostring(luaIndex).." Native index: "..tostring(nativeIndex) end
    end
})

core.register_chatcommand("lua_get_wielded_item", {
    description="Invokes lua_api > get_wielded_item",
    func=function ()
        local player=core.get_player_by_name(playerName)
        
        player:set_wielded_item(testItem)
        local item = player:get_wielded_item()
        player:set_wielded_item(noItem)

        if item then return true, "wielded item returned"
        else return false, "Function returned nil" end
        
    end
})

core.register_chatcommand("native_get_wielded_item", {
    description="Invokes native_api > get_wielded_item",
    func=function ()
        local player=core.get_player_by_name(playerName)
        
        player:set_wielded_item(testItem)
        local item = player:native_get_wielded_item()
        player:set_wielded_item(noItem)

        if item then return true, "wielded item returned"
        else return false, "Function returned nil" end
        
    end
})

core.register_chatcommand("test_get_wielded_item", {
    description="Invokes lua and native get_wielded_item to compare results",
    func=function ()
        local player=core.get_player_by_name(playerName)

        player:set_wielded_item(testItem)
        local luaItem = player:get_wielded_item()
        local nativeItem = player:native_get_wielded_item()
        player:set_wielded_item(noItem)

        if luaItem ~= nil and dump(luaItem) == dump(nativeItem) then return true, "Same wielded item returned"
        else return false, "Lua item: "..dump(luaItem).."Native item: "..dump(nativeItem) end
    end
})

core.register_chatcommand("lua_set_wielded_item", {
    description="Invokes lua_api > set_wielded_item",
    func = function ()
        local player = core.get_player_by_name(playerName)

        player:set_wielded_item(noItem)
        local initItem = player:get_wielded_item()
        player:set_wielded_item(testItem)
        local setItem = player:get_wielded_item()
        player:set_wielded_item(noItem)
        if initItem:get_name() ~= setItem:get_name() then return true, "Function set wielded item"
        else return false, "Function did not set wielded item"..dump(setItem) end
    end
})

core.register_chatcommand("native_set_wielded_item", {
    description="Invokes native_api > set_wielded_item",
    func = function ()
        local player = core.get_player_by_name(playerName)

        player:set_wielded_item(noItem)
        local initItem = player:get_wielded_item()
        player:native_set_wielded_item(testItem)
        local setItem = player:get_wielded_item()
        player:set_wielded_item(noItem)
        if initItem:get_name() ~= setItem:get_name() then return true, "Function set wielded item"
        else return false, "Function did not set wielded item"..dump(setItem) end
    end
})

core.register_chatcommand("test_set_wielded_item", {
    description="Compares set items for lua and native set_wielded_item functions",
    func=function ()
        local player = core.get_player_by_name(playerName)
        
        player:set_wielded_item(noItem)
        local initItem = player:get_wielded_item()

        player:set_wielded_item(testItem)
        local luaItem = player:get_wielded_item()
        player:set_wielded_item(noItem)

        player:native_set_wielded_item(testItem)
        local nativeItem = player:get_wielded_item()
        player:set_wielded_item(noItem)

        if luaItem:get_name() ~= nil and luaItem:get_name() == nativeItem:get_name() then return true, "Lua and native functions set same wielded item"
        else return false, "Lua set item: "..luaItem:get_name().." Native set item: "..nativeItem:get_name() end
    end
})

local testAg = {fleshy=0, cracky=100}

core.register_chatcommand("lua_set_armor_groups", {
    description="Invokes lua_api > get_armor_groups",
    func=function ()
        local player = core.get_player_by_name(playerName)

        local initAg = player:get_armor_groups()
        player:set_armor_groups(testAg)
        local setAg = player:get_armor_groups()
        player:set_armor_groups(initAg)

        if dump(initAg) ~= dump(setAg) then return true, "Armor groups value set"
        else return false, "Armor groups value not set" end
    end
})

core.register_chatcommand("native_set_armor_groups", {
    description="Invokes native_api > get_armor_groups",
    func=function ()
        local player = core.get_player_by_name(playerName)

        local initAg = player:get_armor_groups()
        player:native_set_armor_groups(testAg)
        local setAg = player:get_armor_groups()
        player:set_armor_groups(initAg)

        if dump(initAg) ~= dump(setAg) then return true, "Armor groups value set"
        else return false, "Armor groups value not set" end
    end
})

core.register_chatcommand("test_set_armor_groups", {
    description="Compares output of Lua and native API for set_armor_groups",
    func=function ()
        local player = core.get_player_by_name(playerName)

        local initAg = player:get_armor_groups()
        player:set_armor_groups(testAg)
        local luaAg = player:get_armor_groups()
        player:set_armor_groups(initAg)
        player:native_set_armor_groups(testAg)
        local nativeAg = player:get_armor_groups()
        player:set_armor_groups(initAg)
        
        if luaAg ~= nil and dump(luaAg) == dump(nativeAg) then return true, "Lua and native functions set AG to same value"
        else return false, "Lua AG: "..dump(luaAg).."Native AG: "..dump(nativeAg) end
    end
})

core.register_chatcommand("lua_get_armor_groups", {
    description="Invokes lua_api > get_armor_groups",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local ag = player:get_armor_groups()
        if ag then return true, "Armor groups returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_armor_groups", {
    description="Invokes native_api > get_armor_groups",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local ag = player:native_get_armor_groups()
        if ag then return true, "Armor groups returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_armor_groups", {
    description="Compares output of Lua and native API for armor_groups",
    func= function()
        local player = core.get_player_by_name(playerName)
        
        local luaAg = player:get_armor_groups()
        local nativeAg = player:native_get_armor_groups()

        if luaAg ~= nil and dump(luaAg) == dump(nativeAg) then return true, "Lua and native functions returned same armor group"
        else return false, "Lua AG: "..dump(luaAg).." Native AG: "..dump(nativeAg) end
    end
})

local testRange={x=3, y=3}
local testSpeed=3.0
local testBlend=1.0
local testLoop=false

core.register_chatcommand("lua_set_animation", {
    description="Invokes lua_api > set_animation",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initRange, initSpeed, initBlend, initLoop = player:get_animation()
        player:set_animation(testRange, testSpeed, testBlend, testLoop)
        local setRange, setSpeed, setBlend, setLoop = player:get_animation()
        player:set_animation(initRange, initSpeed, initBlend, initLoop)
        if initRange ~= setRange and initSpeed ~= setSpeed and initBlend ~= setBlend and initLoop ~= setLoop then return true, "Set animation"
        else return false, "Didn't set animation" end
    end
})


core.register_chatcommand("native_set_animation", {
    description="Invokes native_api > set_animation",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initRange, initSpeed, initBlend, initLoop = player:get_animation()
        player:native_set_animation(testRange, testSpeed, testBlend, testLoop)
        local setRange, setSpeed, setBlend, setLoop = player:get_animation()
        player:set_animation(initRange, initSpeed, initBlend, initLoop)
        if initRange ~= setRange and initSpeed ~= setSpeed and initBlend ~= setBlend and initLoop ~= setLoop then return true, "Set animation"
        else return false, "Didn't set animation" end
    end
})

core.register_chatcommand("test_set_animation", {
    description="Compares output of Lua and native set_animation functions",
    func=function ()
        local player = core.get_player_by_name(playerName)
        local initRange, initSpeed, initBlend, initLoop = player:get_animation()
        
        player:set_animation(testRange, testSpeed, testBlend, testLoop)
        local luaRange, luaSpeed, luaBlend, luaLoop = player:get_animation()

        player:set_animation(initRange, initSpeed, initBlend, initLoop)

        player:native_set_animation(testRange, testSpeed, testBlend, testLoop)
        local nativeRange, nativeSpeed, nativeBlend, nativeLoop = player:get_animation()

        player:set_animation(initRange, initSpeed, initBlend, initLoop)

        if (luaRange ~= nil and luaSpeed ~= nil and luaBlend ~= nil and luaLoop ~= nil)
        and (dump(luaRange) == dump(nativeRange) and luaSpeed == nativeSpeed and luaBlend == nativeBlend and luaLoop == nativeLoop)
        then return true, "Lua and native functions set animation to same values"
        else return false, "Lua and native functions did not set animation to same values" end
    end
})


core.register_chatcommand("lua_get_animation", {
    description="Invokes lua_api > get_animation",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local range, speed, blend, loop = player:get_animation()
        if (range and speed and blend and loop) then return true, "Animation returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_animation", {
    description="Invokes native_api > get_animation",
    func = function ()
        local player = core.get_player_by_name(playerName)
        local range, speed, blend, loop = player:native_get_animation()
        if (range and speed and blend and loop) then return true, "Animation returned"
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_animation", {
    description="Compares output of Lua and native API for get_animation",
    func=function ()
        local player=core.get_player_by_name(playerName)
        local luaRange, luaSpeed, luaBlend, luaLoop = player:get_animation()
        local nativeRange, nativeSpeed, nativeBlend, nativeLoop = player:native_get_animation()
        if (luaRange and luaSpeed and luaBlend and luaLoop) and (dump(nativeRange) == dump(luaRange)
        and luaSpeed == nativeSpeed and luaBlend == nativeBlend and luaLoop == nativeLoop) then 
        return true, "Lua and native animation same"
        else return false, "Lua and native animations different" end

    end
})

core.register_chatcommand("lua_get_local_animation", {
    description="Invokes lua_api > get_local_animation",
    func=function ()
        local player=core.get_player_by_name(playerName)

    end
})