--Storage class test mod

minetest.log("--Storage class tests--")

--get_mod_storage()
--lua test
minetest.register_chatcommand("lua_storage_get_mod_storage",
{
	description = "Test storage class method get_mod_storage() (lua version).",
	func = function(self)
		local player = minetest.get_player_by_name("singleplayer");
		local pos = player:get_pos();
		local mods = player:get_mod_storage();
		minetest.log(mods);
		--TODO: test and check if get_mod_storage() actually returns the mods?
		--TODO: compare get_mod_storage() output with actual mod list, test with different mods enabled to see if there's a difference
	end
})

--TODO: see if there's any other functions that can be tested in the storage class, e.g. Initialize, StorageRef functions?