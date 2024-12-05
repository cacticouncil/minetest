--Nodemeta class test mod

minetest.log("--Nodemeta class tests--")

--get_inventory()
--lua test
minetest.register_chatcommand("lua_nodemeta_get_inventory",
{
	description = "Test nodemeta class method get_inventory() (lua version).",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local pos = player:get_pos();
		minetest.set_node({x = pos.x + 2, y = pos.y, z = pos.z}, {name = "chest:chest"});
		
		local meta = minetest.get_meta({x = pos.x + 2, y = pos.y, z = pos.z});
		local itemstack = ItemStack("chest:chest");
		local inv = meta:get_inventory();
		inv:set_stack("main", 1, itemstack);
		
		local res = inv:contains_item("main", itemstack);
		minetest.remove_node({x = pos.x + 2, y = pos.y, z = pos.z});
		
		if(res == true) then
			return true, "Success, get_inventory() returns the right InvRef"
		else
			return false, "Failure, get_inventory() returns the right InvRef"
		end
	end
})

--native test
minetest.register_chatcommand("native_nodemeta_get_inventory",
{
	description = "Test nodemeta class method get_inventory() (native version).",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local pos = player:get_pos();
		minetest.set_node({x = pos.x + 2, y = pos.y, z = pos.z}, {name = "chest:chest"});
		
		local meta = minetest.get_meta({x = pos.x + 2, y = pos.y, z = pos.z});
		local itemstack = ItemStack("chest:chest");
		local inv = meta:native_get_inventory();
		inv:set_stack("main", 1, itemstack);
		
		local res = inv:contains_item("main", itemstack);
		minetest.remove_node({x = pos.x + 2, y = pos.y, z = pos.z});
		
		if(res == true) then
			minetest.log("Success in native get inventory()!");
			return true, "Success, native_get_inventory() returns the right InvRef"
		else
			return false, "Failure, native_get_inventory() returns the right InvRef"
		end
	end
})

--comparison test
minetest.register_chatcommand("test_nodemeta_get_inventory",
{
	description = "Compares outputs of lua and native versions of nodemeta class's method, get_inventory()",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local pos = player:get_pos();
		minetest.set_node({x = pos.x + 2, y = pos.y, z = pos.z}, {name = "chest:chest"});
		minetest.set_node({x = pos.x + 2, y = pos.y + 1, z = pos.z}, {name = "chest:chest"});
		
		local l_meta = minetest.get_meta({x = pos.x + 2, y = pos.y, z = pos.z});
		local n_meta = minetest.get_meta({x = pos.x + 2, y = pos.y + 1, z = pos.z});
		
		local itemstack = ItemStack("chest:chest");
		local l_inv = l_meta:get_inventory();
		local n_inv = n_meta:native_get_inventory();
		l_inv:set_stack("main", 1, itemstack);
		n_inv:set_stack("main", 1, itemstack);
		
		local l_res = l_inv:contains_item("main", itemstack);
		local n_res = n_inv:contains_item("main", itemstack);
		minetest.remove_node({x = pos.x + 2, y = pos.y, z = pos.z});
		minetest.remove_node({x = pos.x + 2, y = pos.y + 1, z = pos.z});
		
		if(l_res == n_res) then
			minetest.log("SUCCESS!!!");
			return true, "Success, get_inventory() and native_get_inventory() return the same InvRef"
		else
			return false, "Failure, get_inventory() and native_get_inventory() return different InvRef"
		end
	end
})



--mark_as_private
--lua test
minetest.register_chatcommand("lua_nodemeta_mark_as_private",
{
	description = "Test nodemeta class method mark_as_private() (lua version).",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local pos = player:get_pos();
		minetest.set_node({x = pos.x + 2, y = pos.y, z = pos.z}, {name = "chest:chest"});
		
		local meta = minetest.get_meta({x = pos.x + 2, y = pos.y, z = pos.z});
		meta:set_string("secret message", "NO ACCESS");
		meta:mark_as_private("secret message");
		
		if(meta:get_int("secret message") == 1) then
			minetest.log("WARNING! Private Variable Accessed");
		else
			minetest.log("Variable Not Accessed");
		end
		
		meta:set_string("not secret", "ACCESSED");
		if(meta:get_int("not secret") == 1) then
			minetest.log("Non-private var accessed");
		else
			minetest.log("WARNING! Non-private var unable to be accessed");
		end
		
		minetest.remove_node({x = pos.x + 2, y = pos.y, z = pos.z});
		
		
		minetest.set_node({x = pos.x + 2, y = pos.y + 1, z = pos.z}, {name = "chest:chest"});
		local meta2 = minetest.get_meta({x = pos.x + 2, y = pos.y + 1, z = pos.z});
		meta2:set_string("secret", "some password");
		minetest.chat_send_all("Test print before privating var");
		--minetest.run_server_chatcommand("kick", player_name)
		minetest.chat_send_all(meta2:get_string("secret"));
		meta2:mark_as_private("secret");
		minetest.chat_send_all("Test print after privating var");
		minetest.chat_send_all(meta2:get_string("secret"));
		
	end
})

--native test
minetest.register_chatcommand("native_nodemeta_mark_as_private",
{
    description = "Test nodemeta class method mark_as_private() (native version).",
    func = function(self)
    local player = minetest.get_player_by_name("singleplayer");
    local pos = player:get_pos();
    local testing = {x=pos.x+2, y=pos.y, z= pos.z}
    minetest.set_node(testing, {name = "chest:chest"})
    local meta = minetest.get_meta(testing)
    meta:set_string("test_message","NO ACCESS")
    meta:native_mark_as_private("test_message")

    local private_access =meta:get_int("test_message")
    if private_access == 1 then
        minetest.log("WARNING! private var accessed");
    else
        minetest.log("private var unable to be accessed");
    end

    meta:set_string("public_message", "this is public");
    local public_access = meta:get_int("public_message")
    if public_access == 1 then
        minetest.log("Public var access successful");
    else
        minetest.log("WARNING! public var access unsuccessful");
    end
    minetest.remove_node(testing);

    local testing2 = {x=pos.x+2, y=pos.y+1, z= pos.z}
    minetest.set_node(testing2, {name = "chest:chest"});
    local meta2 = minetest.get_meta(testing2);
    meta2:set_string("secret_to_change", "something to be changed");
    minetest.chat_send_all("Test print before privating var");
    --minetest.run_server_chatcommand("kick", player_name)
    minetest.chat_send_all(meta2:get_string("secret_to_change"));
    meta2:native_mark_as_private("secret_to_change");
    minetest.chat_send_all("Test print after privating var");
    minetest.chat_send_all(meta2:get_string("secret_to_change"));
end
})

--comparison test
minetest.register_chatcommand("test_nodemeta_mark_as_private",
{
	description = "Compares outputs of lua and native versions of nodemeta class's method, mark_as_private()",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local l_inv = player:get_inventory();
		local n_inv = player:native_get_inventory();
		if(l_inv == n_inv) then
			return true, "Success, mark_as_private() and native_mark_as_private() return the same values"
		else
			return false, "Failure, mark_as_private() and native_mark_as_private() return different values"
		end
	end
})





minetest.register_chatcommand("test_nodemeta",
{
	description = "testing all nodemeta methods",
	func = function()

		local methods =
		{
			"get_inventory"--,
			--"mark_as_private"
		}

		return native_tests.test_class("nodemeta", methods), 
		"Nodemeta tests completed. See server_dump.txt for details."
	end
})
