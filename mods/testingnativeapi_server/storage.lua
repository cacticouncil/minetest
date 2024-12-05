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
	end
})