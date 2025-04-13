local modpath = core.get_modpath("testingnativeapi_server")
InitEnvVars = assert(loadfile(modpath.."/env.lua", "t"))
InitEnvVars()

--Gets name of current player and lets you change it by sending a chat message - needed for tests
local playerName = "singleplayer"

core.register_on_joinplayer(function(player)
    playerName = player:get_player_name()
end)

core.register_on_chat_message(function(name, message)
    playerName = name
    core.chat_send_player(name, "Test player name changed to: ".. name)
end)

--Can't catch cancelled shutdown notification messages, so visually observed cancellation for all three functions
core.register_chatcommand("lua_request_shutdown", {
    description="Invokes lua_api > request_shutdown",
    func  = function(self)
        core.request_shutdown("lua shutdown requested", true, 1)
        core.request_shutdown("lua canceling shutdown", true, -1)
        return true
    end    
})

core.register_chatcommand("native_request_shutdown", {
    description="Invokes native_api > request_shutdown",
    func  = function(self)
        core.native_request_shutdown("lua shutdown requested", true, 100)
        core.native_request_shutdown("lua canceling shutdown", true, -1)
        return true
    end 
})

core.register_chatcommand("test_request_shutdown", {
    description="Tests both lua and native shutdowns",
    func = function (self)
        core.request_shutdown("lua shutdown requested", true, 100)
        core.request_shutdown("lua canceling shutdown", true, -1)
        core.native_request_shutdown("lua shutdown requested", true, 100)
        core.native_request_shutdown("lua canceling shutdown", true, -1)
        return true
    end
})

--may require visual confirmation because server status may change between function calls
core.register_chatcommand("lua_get_server_status", {
    description="Invokes lua_api > get_server_status",
    func = function (self)
        local status = core.get_server_status()
        if status ~= nil then return true, "Sever status: "..status
        else return false, "Server status not gotten" end
    end
})

core.register_chatcommand("native_get_server_status", {
    description="Invokes native_api > get_server_status",
    func = function (self)
        local status = core.native_get_server_status()
        if status ~= nil then return true, "Sever status: "..status
        else return false, "Server status not gotten" end
    end
})

core.register_chatcommand("test_get_server_status", {
    description="Invokes both lua and native server statuses",
    func = function (self)
        local luaStatus = core.get_server_status()
        local nativeStatus = core.native_get_server_status()
        if luaStatus == nativeStatus then return true, "Statuses are the same"
        else return false, "Lua status: "..luaStatus.."\nnative status: "..nativeStatus end
    end
})

--may require visual confirmation because server status may change between function calls
core.register_chatcommand("lua_get_server_uptime", {
    description="Invokes lua_api > get_server_uptime",
    func = function (self)
        local uptime = core.get_server_uptime()
        if uptime ~= nil then return true, "Sever uptime: "..uptime
        else return false, "Server uptime not gotten" end
    end
})

core.register_chatcommand("native_get_server_uptime", {
    description="Invokes native_api > get_server_uptime",
    func = function (self)
        local uptime = core.native_get_server_uptime()
        if uptime ~= nil then return true, "Sever uptime: "..uptime
        else return false, "Server uptime not gotten" end
    end
})

core.register_chatcommand("test_get_server_uptime", {
    description="Compares lua and native functions for get_server_uptime",
    func = function (self)
        local luaUp = core.get_server_uptime()
        local nativeUp = core.native_get_server_uptime()
        if luaUp == nativeUp then return true, "Server uptimes were the same"
        else return false, "Lua uptime: "..luaUp.." Native uptime: "..nativeUp end
    end
})

--visually observed results in debug console
core.register_chatcommand("lua_print", {
    description="Invokes lua_api > print",
    func = function ()
        print("lua print invoked")
        return true
    end
})
--native print only works when called from core
core.register_chatcommand("native_print", {
    description="Invokes native_api > print",
    func = function ()
        core.native_print("native print invoked")
        return true
    end
})

core.register_chatcommand("test_print", {
    description="Invokes native_api > print and lua_api > print",
    func = function ()
        print("lua print invoked")
        core.native_print("native print invoked")
        return true
    end
})

--visually observed results in debug console 
core.register_chatcommand("lua_chat_send_all", {
    description="Invokes lua_api > chat_send_all",
    func = function (self)
        core.chat_send_all("lua chat message sent")
    end
})

core.register_chatcommand("native_chat_send_all", {
    description="Invokes native_api > chat_send_all",
    func = function (self)
        core.native_chat_send_all("native chat message sent")
    end
})

core.register_chatcommand("test_chat_send_all", {
    description="Invokes native_api > chat_send_all",
    func = function (self)
        core.chat_send_all("lua chat message sent")
        core.native_chat_send_all("native chat message sent")
    end
})

--visually observed results in debug console 
core.register_chatcommand("lua_chat_send_player", {
    description="Invokes lua_api > chat_send_player",
    func = function (self)
        core.chat_send_player(playerName, "lua chat message to "..playerName.." sent")
    end
})

core.register_chatcommand("native_chat_send_player", {
    description="Invokes native_api > chat_send_player",
    func = function (self)
        core.native_chat_send_player(playerName, "Native chat message to "..playerName.." sent")
    end
})

core.register_chatcommand("test_chat_send_player", {
    description="Invokes both lua_api and native_api chat_send_player",
    func = function (self)
        core.chat_send_player(playerName, "lua chat message to "..playerName.." sent")
        core.native_chat_send_player(playerName, "Native chat message to "..playerName.." sent")
    end
})

core.register_chatcommand("lua_get_player_privs", {
    description="Invokes lua_api > get_player_privs",
    func = function (self)
        local privs = core.get_player_privs(playerName)
        if privs ~= nil then return true, "Got player privs"
        else return false, "Did not get player privs" end
    end
})

core.register_chatcommand("native_get_player_privs", {
    description="Invokes native_api > get_player_privs",
    func = function (self)
        local privs = core.native_get_player_privs(playerName)
        if privs ~= nil then return true, "Got player privs"
        else return false, "Did not get player privs" end
    end
})

core.register_chatcommand("test_get_player_privs", {
    description="Compares get_player_privs output for lua and native APIs",
    func = function (self)
        local luaPrivs = core.get_player_privs(playerName)
        local nativePrivs = core.native_get_player_privs(playerName)
        if dump(luaPrivs) == dump(nativePrivs) then return true, "Lua and native privs identical"
        else return false, "Lua privs: "..dump(luaPrivs).."\nnative privs: "..dump(nativePrivs) end
    end
})

core.register_chatcommand("lua_get_player_ip", {
    description="Invokes lua_api > get_player_ip",
    func = function (self)
        local ip = core.get_player_ip(playerName)
        if ip ~= nil then return true, "Player ip returned"
        else return false, "Player ip not returned" end
    end
})

core.register_chatcommand("native_get_player_ip", {
    description="Invokes native_api > get_player_ip",
    func = function (self)
        local ip = core.native_get_player_ip(playerName)
        if ip ~= nil then return true, "Player ip returned"
        else return false, "Player ip not returned" end
    end
})

core.register_chatcommand("test_get_player_ip", {
    description="Compares get_player_ip output for lua and native APIs",
    func = function (self)
        local luaip = core.get_player_ip(playerName)
        local nativeip = core.native_get_player_ip(playerName)
        if luaip == nativeip then return true, "Lua and native ips identical"
        else return false, "Lua ip: "..luaip.."\nnative ip: "..nativeip end
    end
})

core.register_chatcommand("lua_get_player_information", {
    description="Invokes lua_api > get_player_information",
    func = function (self)
        local info = core.get_player_ip(playerName)
        if info ~= nil then return true, "Player information returned"
        else return false, "Player information not returned" end
    end
})

core.register_chatcommand("native_get_player_information", {
    description="Invokes native_api > get_player_information",
    func = function (self)
        local info = core.native_get_player_ip(playerName)
        if info ~= nil then return true, "Player information returned"
        else return false, "Player information not returned" end
    end
})

core.register_chatcommand("test_get_player_information", {
    description="Compares get_player_information output for lua and native APIs",
    func = function ()
        local luaInfo = core.get_player_information(playerName)
        local nativeInfo = core.get_player_information(playerName)
        if dump(luaInfo) == dump(nativeInfo) then return true, "Lua and native player info identical"
        else return false, "Lua info: "..dump(luaInfo).."native info: "..dump(nativeInfo) end
    end
})

local mockPlayer = {
    is_player = function ()
        return true
    end,
    get_player_name = function ()
        return "mockPlayer"
    end
}

core.register_chatcommand("lua_get_ban_list", {
    description="Invokes lua_api > get_ban_list",
    func = function (self)
        core.ban_player(playerName)
        local banlist = core.get_ban_list()
        core.unban_player_or_ip(playerName)
        if banlist ~= "" then return true, banlist
        else return false, "No ban list returned" end
    end
})

core.register_chatcommand("native_get_ban_list", {
    description="Invokes native_api > get_ban_list",
    func = function (self)
        core.ban_player(playerName)
        local banlist = core.native_get_ban_list()
        core.unban_player_or_ip(playerName)
        if banlist ~= "" then return true, banlist
        else return false, "No ban list returned" end
    end
})

core.register_chatcommand("test_get_ban_list", {
    description="Compares output of lua and native get_ban_list",
    func= function (self)
        core.ban_player(playerName)
        local luaBanlist = core.get_ban_list()
        core.unban_player_or_ip(playerName)

        core.ban_player(playerName)
        local nativeBanlist = core.native_get_ban_list()
        core.unban_player_or_ip(playerName)

        if luaBanlist ~= "" and luaBanlist == nativeBanlist then return true, "Banlists were the same"
        else return false, "Lua banlist: "..luaBanlist.." Native banlist: "..nativeBanlist end
    end
})

core.register_chatcommand("lua_get_ban_description", {
    description="Invokes lua_api > get_ban_description",
    func = function (self)
        core.ban_player(playerName)
        local banDesc = core.get_ban_description(playerName)
        core.unban_player_or_ip(playerName)
        if banDesc ~= "" then return true, banDesc
        else return false, "No ban list returned" end
    end
})

core.register_chatcommand("native_get_ban_description", {
    description="Invokes native_api > get_ban_description",
    func = function (self)
        core.ban_player(playerName)
        local banDesc = core.native_get_ban_description(playerName)
        core.unban_player_or_ip(playerName)
        if banDesc ~= "" then return true, banDesc
        else return false, "No ban list returned" end
    end
})

core.register_chatcommand("test_get_ban_description", {
    description="Compares output of lua and native get_ban_description",
    func= function (self)
        core.ban_player(playerName)
        local luaDesc = core.get_ban_description(playerName)
        core.unban_player_or_ip(playerName)

        core.ban_player(playerName)
        local nativeDesc = core.native_get_ban_description(playerName)
        core.unban_player_or_ip(playerName)

        if luaDesc ~= "" and luaDesc == nativeDesc then return true, "Ban descriptions were the same"
        else return false, "Lua ban desc: "..luaDesc.." Native ban desc: "..nativeDesc end
    end
})

--can momentarily ban yourself to test function
core.register_chatcommand("lua_ban_player", {
    description="Invokes lua_api > ban_player",
    func = function (self)
        local banned = core.ban_player(playerName)
        core.unban_player_or_ip(playerName)
        return banned, "Player banned: "..tostring(banned)
    end
})

core.register_chatcommand("native_ban_player", {
    description="Invokes native_api > ban_player",
    func = function (self)
        local banned = core.native_ban_player(playerName)
        core.unban_player_or_ip(playerName)
        return banned, "Player banned: "..tostring(banned)
    end
})

core.register_chatcommand("test_ban_player", {
    description="Compares ban result for lua and native ban_player",
    func= function (self)
        local luaBanned = core.ban_player(playerName)
        core.unban_player_or_ip(playerName)
        local nativeBanned = core.native_ban_player(playerName)
        core.unban_player_or_ip(playerName)
        if luaBanned and nativeBanned then return true, "Lua and native ban_player worked"
        else return false, "Lua ban"..tostring(luaBanned).." Native ban: "..tostring(nativeBanned) end
    end
})

--must visually confirm because API has no unkick (maybe future dev can add automation?)
core.register_chatcommand("lua_kick_player", {
    description="Invokes lua_api > kick_player",
    func = function (self)
        core.kick_player(playerName)
    end
})

core.register_chatcommand("native_kick_player", {
    description="Invokes native_api > kick_player",
    func = function (self)
        core.native_kick_player(playerName)
    end
})

--must open 2 other Minetest instances and join with usernames mockclient1 and mockclient2 to use
core.register_chatcommand("test_kick_player", {
    description="Tests kicking players in native and lua APIs",
    func = function (self)
        core.kick_player("mockclient1")
        core.native_kick_player("mockclient2")
        local players = core.get_connected_players()
        local playerCt = 0
        for _ in ipairs(players) do
            playerCt = playerCt+1
        end
        if playerCt == 1 then return true, "Players succesfully kicked"
        else return false, "Players were not succesfully kicked"..dump(players) end
    end
})

--[[
Must run on three cases for comprehensive testing:
1. mockplayer doesn't exist
2. mockplayer exists but is offline
3. mockplayer is online
]]

core.register_chatcommand("lua_remove_player", {
    description="Invokes lua_api > remove_player",
    func = function (self)
        local code = core.remove_player("mockplayer")
        if code == 0 then return true, "playerRemoval successful"
        elseif code == 1 then return true, "player did not exist"
        elseif code == 2 then return true, "player currently online"
        else return false, "Unknown status code" end
    end
})

core.register_chatcommand("native_remove_player", {
    description="Invokes native_api > remove_player",
    func = function (self)
        local code = core.native_remove_player("mockplayer")
        if code == 0 then return true, "playerRemoval successful"
        elseif code == 1 then return true, "player did not exist"
        elseif code == 2 then return true, "player currently online"
        else return false, "Unknown status code" end
    end
})

--make sure that mockplayer 1 and mockplayer 2 have the same status
core.register_chatcommand("test_remove_player", {
    description="Tests output of remove_player from Lua and native APIs",
    func = function (self)
        local luaCode = core.remove_player("mockplayer1")
        local nativeCode = core.remove_player("mockplayer2")
        if luaCode == nativeCode then return true, "Lua and native functions return same value"
        else return false, "Lua code: "..luaCode.. " Native code: "..nativeCode end
    end
})

core.register_chatcommand("lua_unban_player_or_ip", {
    description="Invokes lua_api > unban_player_or_ip",
    func = function ()
        core.ban_player(playerName)
        core.unban_player_or_ip(playerName)
        core.ban_player(playerName)
        core.unban_player_or_ip(core.get_player_ip(playerName))
        --no false condition because you will just be banned if test fails
        return true, "Player was unbanned by Lua function"
    end
})

core.register_chatcommand("native_unban_player_or_ip", {
    description="Invokes native_api > unban_player_or_ip",
    func = function ()
        core.ban_player(playerName)
        core.native_unban_player_or_ip(playerName)
        core.ban_player(playerName)
        core.unban_player_or_ip(core.get_player_ip(playerName))
        return true, "Player was unbanned by native function"
    end
})

core.register_chatcommand("test_unban_player_or_ip", {
    description="Tests unban_player_or_ip for both Lua and native APIs",
    func = function ()
        core.ban_player(playerName)
        core.unban_player_or_ip(playerName)
        core.ban_player(playerName)
        core.unban_player_or_ip(core.get_player_ip(playerName))
        return true, "Both Lua and native functions unban player"
    end
})

local testFormspec = {
    "formspec_version[4]",
    "size[2,2]",
    "position[0,0.5]",
    "anchor[0,0.5]",
    "button[1.5,2.3;3,0.8;cringe;Cringe]"
}

core.register_chatcommand("lua_show_formspec", {
    description="Invokes lua_api > show_formspec",
    func = function (self)
        local status = core.show_formspec(playerName, "testingnativeapi_server:luaformspec", table.concat(testFormspec, ""))
        core.close_formspec(playerName, "testingnativeapi_server:luaformspec")        
        if status == true then return true, "Formspec shown"
        else return false, "Formspec not shown" end
    end
})

core.register_chatcommand("native_show_formspec", {
    description="Invokes native_api > show_formspec",
    func = function (self)
        local status = core.native_show_formspec(playerName, "testingnativeapi_server:nativeformspec", table.concat(testFormspec, ""))
        core.close_formspec(playerName, "testingnativeapi_server:nativeformspec")        
        if status == true then return true, "Formspec shown"
        else return false, "Formspec not shown" end
    end
})

core.register_chatcommand("test_show_formspec", {
    description="Compares output of lua and native show_formspecs",
    func = function()
        local luaStatus = core.show_formspec(playerName, "testingnativeapi_server:luaformspec", table.concat(testFormspec, ""))
        core.close_formspec(playerName, "testingnativeapi_server:luaformspec")
        
        local nativeStatus = core.native_show_formspec(playerName, "testingnativeapi_server:nativeformspec", table.concat(testFormspec, ""))
        core.close_formspec(playerName, "testingnativeapi_server:nativeformspec")

        if luaStatus and nativeStatus then return true, "Both Lua and native formspecs shown"
        else return false, "Lua formspec shown: "..tostring(luaStatus).." Native formspec shown: "..tostring(nativeStatus) end
    end
})

--command only works during load time
local luaModname = core.get_current_modname()
local nativeModname = core.native_get_current_modname()
core.register_chatcommand("lua_get_current_modname", {
    description="Invokes lua_api > get_current_modname",
    func=function ()
        if luaModname then return true, "Mod name returned"
        else return false, "Mod name has not been returned" end
    end
})

core.register_chatcommand("native_get_current_modname", {
    description="Invokes native_api > get_current_modname",
    func=function ()
        if nativeModname then return true, "Mod name returned"
        else return false, "Mod name has not been returned" end
        end
})

core.register_chatcommand("test_get_current_modname", {
    description="Tests output of Lua and native get_current_modname",
    func = function ()
        if luaModname ~= nil and luaModname == nativeModname then return true, "Mod names identical"
        else return false, "Lua modname: "..tostring(luaModname).." Native modname: "..tostring(nativeModname) end
    end
})

core.register_chatcommand("lua_get_modpath", {
    description="Invokes lua_api > get_modpath",
    func = function()
        local path = core.get_modpath("default")
        if path then return true, "Path returned" 
        else return false, "Path not returned" end
    end
})

core.register_chatcommand("native_get_modpath", {
    description="Invokes native_api > get_modpath",
    func = function()
        local path = core.native_get_modpath("default")
        if path then return true, "Path returned" 
        else return false, "Path not returned" end
    end
})

core.register_chatcommand("test_get_modpath", {
    description="Tests output of lua and native get_modpath functions",
    func = function ()
        local luaPath = core.get_modpath("default")
        local nativePath = core.native_get_modpath("default")
        if luaPath ~= nil and luaPath == nativePath then return true, "Lua and native modpaths identical"
        else return false, "Lua and native modpaths not identical" end
    end
})

core.register_chatcommand("lua_get_modnames", {
    description="Invokes lua_api > get_modnames",
    func = function ()
        local modnames = core.get_modnames()
        if modnames then return true, "Returned modnames: \n"..dump(modnames)
        else return false, "Modnames not returned" end
    end
})

core.register_chatcommand("native_get_modnames", {
    description="Invokes native_api > get_modnames",
    func = function ()
        local modnames = core.native_get_modnames()
        if modnames then return true, "Returned modnames: \n"..dump(modnames)
        else return false, "Modnames not returned" end
    end
})

core.register_chatcommand("test_get_modnames", {
    description="Compares output of lua and native get_modnames",
    func = function ()
        local luaModnames = core.get_modnames()
        local nativeModnames = core.native_get_modnames()
        if dump(luaModnames) == dump(nativeModnames) then return true, "Lua and native modnames identical"
        else return false, "Lua and native modnames not identical"..dump(luaModnames)..dump(nativeModnames) end
    end
})

core.register_chatcommand("lua_get_worldpath", {
    description="Invokes lua_api > get_worldpath",
    func = function ()
        local path = core.get_worldpath()
        if path then return true, "Path returned: "..path
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_worldpath", {
    description="Invokes native_api > get_worldpath",
    func = function ()
        local path = core.native_get_worldpath()
        if path then return true, "Path returned: "..path
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_worldpath", {
    description="Compares function outputs for lua and native get_worldpath",
    func = function ()
        local luaPath = core.get_worldpath()
        local nativePath = core.native_get_worldpath()

        if luaPath ~= nil and luaPath == nativePath then return true, "Lua and native paths are identical"
        else return false, "Lua path: "..tostring(luaPath).." Native path: "..tostring(nativePath) end
    end
})

core.register_chatcommand("lua_sound_play", {
    description="Invokes lua_api > sound_play",
    func = function ()
        local sound = core.sound_play({name = "default_place_node"})
        core.sound_stop(sound)
        if sound then return true, "Sound was played" end
    end
})

core.register_chatcommand("native_sound_play", {
    description="Invokes native_api > sound_play",
    func = function ()
        local sound = core.native_sound_play({name = "default_place_node"})
        core.sound_stop(sound)
        if sound then return true, "Sound was played" end
    end
})

core.register_chatcommand("test_sound_play", {
    description="Invokes sound_play in both lua and native APIs",
    func = function ()
        local luaSound = core.sound_play({name = "default_place_node"})
        core.sound_stop(luaSound)

        local nativeSound = core.native_sound_play({name = "default_place_node"})
        core.sound_stop(nativeSound)

        if luaSound and nativeSound then return true, "Lua and native sounds were played"
        else return false, "Lua sound handle: "..tostring(luaSound).." Native sound handle: "..tostring(nativeSound) end
    end
})

--must confirm with headphones because API doesn't provide real time audio data
function Sleep (time) 
    local sec = tonumber(os.clock() + time); 
    while (os.clock() < sec) do 
    end 
end

core.register_chatcommand("lua_sound_stop", {
    description="Invokes lua_api > sound_stop",
    func = function ()
        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=2.0, pitch=1.0, loop=true})
        Sleep(4)
        core.sound_stop(sound)
        return true, "If you can no longer hear the sound, the test has passed"
    end
})

core.register_chatcommand("native_sound_stop", {
    description="Invokes lua_api > sound_stop",
    func = function ()
        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=2.0, pitch=1.0, loop=true})
        Sleep(4)
        core.native_sound_stop(sound)
        return true, "If you can no longer hear the sound, the test has passed"
    end
})

core.register_chatcommand("test_sound_stop", {
    description="Plays sound and stops it with lua and native API sound_stop functions",
    func = function ()
        local luaSound = core.sound_play("default_break_glass", {to_player=playerName, gain=2.0, pitch=1.0, loop=true})
        Sleep(4)
        core.sound_stop(luaSound)
        core.chat_send_all("If you can no longer hear the sound, Lua test has passed")
        Sleep(1)
        local nativeSound = core.sound_play("default_break_glass", {to_player=playerName, gain=2.0, pitch=1.0, loop=true})
        Sleep(4)
        core.native_sound_stop(nativeSound)
        core.chat_send_all("If you can no longer hear the sound, native test has passed")
        return true
    end
})

core.register_chatcommand("lua_sound_fade", {
    description="Invokes lua_api > sound_fade",
    func=function ()
        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=3.0, pitch=1.0, loop=true})
        core.sound_fade(sound, 1 ,0)
        Sleep(3.1)
        return true, "If you heard the sound fade out over three seconds, the test has passed"
    end
})

core.register_chatcommand("native_sound_fade", {
    description="Invokes lua_api > sound_fade",
    func=function ()
        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=3.0, pitch=1.0, loop=true})
        core.native_sound_fade(sound, 1 ,0)
        Sleep(3.1)
        return true, "If you heard the sound fade out over three seconds, the test has passed"
    end
})

core.register_chatcommand("test_sound_fade", {
    description="Invokes test_sound_fade for both Lua and native APIs",
    func=function ()
        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=3.0, pitch=1.0, loop=true})
        core.sound_fade(sound, 1 ,0)
        Sleep(3.1)
        core.chat_send_all("If you heard the sound fade out over three seconds, the lua test has passed")

        local sound = core.sound_play("default_place_node", {to_player=playerName, gain=3.0, pitch=1.0, loop=true})
        core.native_sound_fade(sound, 1 ,0)
        Sleep(3.1)
        core.chat_send_all("If you heard the sound fade out over three seconds, the native test has passed")
        return true
    end
})

--Callback that does nothing required by dynamic_add_media
Callback = function (name)
end

local luaMediaAdded = false
local nativeMediaAdded = false

AddLuaMedia = function ()
    local status = core.dynamic_add_media(LuaMediaPath, Callback)
    luaMediaAdded = (luaMediaAdded or status)
    if status then return true, "Media was added"
    else return false, "Media was not added" end
end

AddNativeMedia = function ()
    local status = core.dynamic_add_media(NativeMediaPath, Callback)
    nativeMediaAdded = (luaMediaAdded or status)
    if status then return true, "Media was added"
    else return false, "Media was not added" end
end

--image path must be OUTSIDE of any minetest directory to work
--must restart between tests because there is no way to unload media from cache while game is running (automate later)?
core.register_chatcommand("lua_dynamic_add_media", {
    description="Invokes lua_api > dynamic_add_media",
    func = function ()
        local status, statusString = AddLuaMedia()
        return status, statusString
    end
})

core.register_chatcommand("native_dynamic_add_media", {
    description="Invokes native_api > dynamic_add_media",
    func = function ()
        local status, statusString = AddNativeMedia()
        return status, statusString;
    end
})

core.register_chatcommand("test_dynamic_add_media", {
    description="Compares output of lua and native dynamic_add_media",
    func = function ()
        AddLuaMedia()
        AddNativeMedia()
        if luaMediaAdded and nativeMediaAdded then return true, "Lua and native media were added"
        else return false, "Lua media added: "..tostring(luaMediaAdded).. " Native media added: "..tostring(nativeMediaAdded) end
    end
})

core.register_chatcommand("lua_is_singleplayer", {
    description="Invokes lua_api > is_singleplayer",
    func = function ()
        local isSP = core.is_singleplayer()
        if isSP then return true, "Is singleplayer: "..tostring(isSP)
        else return false, "Function did not return value." end
    end
})

core.register_chatcommand("native_is_singleplayer", {
    description="Invokes native_api > is_singleplayer",
    func = function ()
        local isSP = core.native_is_singleplayer()
        if isSP then return true, "Is singleplayer: "..tostring(isSP)
        else return false, "Function did not return value." end
    end
})

core.register_chatcommand("test_is_singleplayer", {
    description="Compares output of Lua and native is_singeplayer functions",
    func = function ()
        local luaSP = core.is_singleplayer()
        local nativeSP = core.native_is_singleplayer()
        if luaSP ~= nil and luaSP == nativeSP then return true, "Lua and native outputs identical"
        else return false, "Lua output: "..tostring(luaSP).." Native output: "..tostring(nativeSP) end
    end
})

--[[
register custom auth handler to call notify_authentication_modified
boilerplate handler code from : minetest/builtin/game/auth.lua
]]--

local core_auth = core.auth
core.register_authentication_handler({
	get_auth = function(name)
		assert(type(name) == "string")        
		local auth_entry = core_auth.read(name)
		-- If no such auth found, return nil
		if not auth_entry then
			return nil
		end
		-- Figure out what privileges the player should have.
		-- Take a copy of the privilege table
		local privileges = {}
		for priv, _ in pairs(auth_entry.privileges) do
			privileges[priv] = true
		end
		-- If singleplayer, give all privileges except those marked as give_to_singleplayer = false
		if core.is_singleplayer() then
			for priv, def in pairs(core.registered_privileges) do
				if def.give_to_singleplayer then
					privileges[priv] = true
				end
			end
		-- For the admin, give everything
		elseif name == core.settings:get("name") then
			for priv, def in pairs(core.registered_privileges) do
				if def.give_to_admin then
					privileges[priv] = true
				end
			end
		end
		-- All done
		return {
			password = auth_entry.password,
			privileges = privileges,
			last_login = auth_entry.last_login,
		}
	end,
	create_auth = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		core.log('info', "Custom authentication handler adding player '"..name.."'")

		return core_auth.create({
			name = name,
			password = password,
			privileges = core.string_to_privs(core.settings:get("default_privs")),
			last_login = -1,  -- Defer login time calculation until record_login (called by on_joinplayer)
		})
	end,
	delete_auth = function(name)
		assert(type(name) == "string")
		local auth_entry = core_auth.read(name)
		if not auth_entry then
			return false
		end
		core.log('info', "Custom authentication handler deleting player '"..name.."'")
		return core_auth.delete(name)
	end,
	set_password = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		local auth_entry = core_auth.read(name)
		if not auth_entry then
			core.builtin_auth_handler.create_auth(name, password)
		else
			core.log('info', "Custom authentication handler setting password of player '"..name.."'")
			auth_entry.password = password
			core_auth.save(auth_entry)
		end
		return true
	end,
	set_privileges = function(name, privileges, isLua)
		assert(type(name) == "string")
		assert(type(privileges) == "table")
		local auth_entry = core_auth.read(name)
		if not auth_entry then
			auth_entry = core.builtin_auth_handler.create_auth(name,
				core.get_password_hash(name,
					core.settings:get("default_password")))
		end

		-- Run grant callbacks
		for priv, _ in pairs(privileges) do
			if not auth_entry.privileges[priv] then
				core.run_priv_callbacks(name, priv, nil, "grant")
			end
		end

		-- Run revoke callbacks
		for priv, _ in pairs(auth_entry.privileges) do
			if not privileges[priv] then
				core.run_priv_callbacks(name, priv, nil, "revoke")
			end
		end

		auth_entry.privileges = privileges
		core_auth.save(auth_entry)
        
        --choose notification method based on whether caller was Lua test function or not
        if isLua then core.notify_authentication_modified("mockplayer")
        else core.native_notify_authentication_modified("mockplayer") end
	end,
	reload = function()
		core_auth.reload()
		return true
	end,
	record_login = function(name)
		assert(type(name) == "string")
		local auth_entry = core_auth.read(name)
		assert(auth_entry)
		auth_entry.last_login = os.time()
		core_auth.save(auth_entry)
	end,
	iterate = function()
		local names = {}
		local nameslist = core_auth.list_names()
		for k,v in pairs(nameslist) do
			names[v] = true
		end
		return pairs(names)
	end,
})

core.register_on_prejoinplayer(function(name, ip)
	if core.registered_auth_handler ~= nil then
		return -- Don't do anything if custom auth handler registered
	end
	local auth_entry = core_auth.read(name)
	if auth_entry ~= nil then
		return
	end

	local name_lower = name:lower()
	for k in core.builtin_auth_handler.iterate() do
		if k:lower() == name_lower then
			return string.format("\nCannot create new player called '%s'. "..
					"Another account called '%s' is already registered. "..
					"Please check the spelling if it's your account "..
					"or use a different nickname.", name, k)
		end
	end
end)


--must create "mockplayer" auth because you can't remove your own privileges
local authHandler = core.get_auth_handler()
core.register_chatcommand("get_auth_info", {
    description="Helper function that returns all authentication data",
    func=function ()
        return true, dump(authHandler.get_auth("mockplayer"))
    end
})

local testPrivs = {
    interact=nil,
    shout=nil,
    basic_privs=nil,
    privs=nil,
}

core.register_chatcommand("lua_notify_authentication_modified", {
    description="Invokes lua_api > notify_authentication_modified",
    func=function ()
        --called when privs are changed through auth handler, test update notif by getting them through core privileges table
        authHandler.delete_auth("mockplayer")
        authHandler.create_auth("mockplayer", "asdfjkl;")

        local initPrivs = core.get_player_privs("mockplayer")
        authHandler.set_privileges("mockplayer", testPrivs, true)
        local luaPrivs = core.registered_privileges["mockplayer"]
        authHandler.set_privileges("mockplayer", initPrivs, true)

        authHandler.delete_auth("mockplayer")
        if dump(initPrivs) ~= dump(luaPrivs) then return true, "Engine notified of auth change"
        else return false, "Engine not notified of auth change" end
    end
})


core.register_chatcommand("native_notify_authentication_modified", {
    description="Invokes native_api > notify_authentication_modified",
    func=function ()
        --called when privs are changed through auth handler, test update notif by getting them through core privileges table
        authHandler.delete_auth("mockplayer")
        authHandler.create_auth("mockplayer", "asdfjkl;")

        local initPrivs = core.get_player_privs("mockplayer")
        authHandler.set_privileges("mockplayer", testPrivs, false)
        local nativePrivs = core.registered_privileges["mockplayer"]
        authHandler.set_privileges("mockplayer", initPrivs, false)

        authHandler.delete_auth("mockplayer")
        if dump(initPrivs) ~= dump(nativePrivs) then return true, "Engine notified of auth change"
        else return false, "Engine not notified of auth change" end
    end
})

core.register_chatcommand("test_notify_authentication_modified", {
    description="Calls both Lua and native notify_authentication_modified to test functionality",
    func=function ()
        authHandler.delete_auth("mockplayer")
        authHandler.create_auth("mockplayer", "asdfjkl;")

        local initPrivs = core.get_player_privs("mockplayer")
        authHandler.set_privileges("mockplayer", testPrivs, true)
        local luaPrivs = core.registered_privileges["mockplayer"]
        authHandler.set_privileges("mockplayer", initPrivs, true)

        authHandler.delete_auth("mockplayer")

        authHandler.delete_auth("mockplayer")
        authHandler.create_auth("mockplayer", "asdfjkl;")

        local initPrivs = core.get_player_privs("mockplayer")
        authHandler.set_privileges("mockplayer", testPrivs, false)
        local nativePrivs = core.registered_privileges["mockplayer"]
        authHandler.set_privileges("mockplayer", initPrivs, false)

        authHandler.delete_auth("mockplayer")

        if dump(luaPrivs) == dump(nativePrivs) then return true, "Lua and native privs set to same value!"
        else return false, "Lua and native privs not set to same value"..dump(luaPrivs)..dump(nativePrivs) end
    end
})
core.register_chatcommand("lua_get_last_run_mod", {
    description="Invokes lua_api > get_last_run_mod",
    func = function ()
        local mod = core.get_last_run_mod()
        if mod then return true, "Last run mod: "..tostring(mod)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("native_get_last_run_mod", {
    description="Invokes native_api > get_last_run_mod", 
    func=function ()
        local mod = core.native_get_last_run_mod()
        if mod then return true, "Last run mod: "..tostring(mod)
        else return false, "Function returned nil" end
    end
})

core.register_chatcommand("test_get_last_run_mod", {
    description="Compares output of Lua and native get_last_run_mod",
    func = function ()
        local luaMod = core.get_last_run_mod()
        local nativeMod = core.native_get_last_run_mod()

        if luaMod ~= nil and luaMod == nativeMod then return true, "Lua and native function outputs identical"
        else return "Lua output: "..tostring(luaMod).." Native output: "..tostring(nativeMod) end
    end
})

core.register_chatcommand("lua_set_last_run_mod", {
    description="Invokes lua_api > set_last_run_mod",
    func = function ()
        local origMod = core.get_last_run_mod()
        core.set_last_run_mod("default")
        local newMod = core.get_last_run_mod()
        core.set_last_run_mod(origMod)

        if (origMod ~= nil and newMod ~= nil) and origMod ~= newMod then return true, "Last run mod set succesfully"
        else return false, "Last run mod set unsuccessfully to: "..tostring(newMod) end
    end
})

core.register_chatcommand("native_set_last_run_mod", {
    description="Invokes native_api > set_last_run_mod",
    func = function ()
        local origMod = core.get_last_run_mod()
        core.native_set_last_run_mod("default")
        local newMod = core.get_last_run_mod()
        core.set_last_run_mod(origMod)

        if (origMod ~= nil and newMod ~= nil) and origMod ~= newMod then return true, "Last run mod set succesfully"
        else return false, "Last run mod set unsuccessfully to: "..tostring(newMod) end
    end
})

core.register_chatcommand("test_set_last_run_mod", {
    description="Compares output of lua and native set_last_run_mod",
    func = function ()
        local origMod = core.get_last_run_mod()

        core.set_last_run_mod("default")
        local luaMod = core.get_last_run_mod()
        core.set_last_run_mod(origMod)

        core.native_set_last_run_mod("default")
        local nativeMod = core.get_last_run_mod()
        core.set_last_run_mod(origMod)

        if luaMod ~= nil and luaMod == nativeMod then return true, "Lua and native mods set last run mod to same value"
        else return false, "Lua mod: "..tostring(luaMod).." Native mod: "..tostring(nativeMod) end
    end
})