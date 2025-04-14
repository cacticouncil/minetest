local playerName = "singleplayer"
core.register_on_joinplayer(function(player)
    playerName = player:get_player_name()
end)

local rightClicked = false
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
        --single punch will always kill entity because it has 1 health
        core.chat_send_all(dump(player))
        entity:punch(player, 0.0, test_tool_caps, nil)
        if entity:get_pos() == nil then return true, "Entity was punched"
        else return false, "Entity was not punched" end
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