
-- LukeWasHere block (A Luke test mod)
-- A block which does absolutely nothing.


function register_wasm_mod(name, description, texture, material)
    minetest.register_node(":" .. name, {
        description = description,
        groups = {oddly_breakable_by_hand=2},
        tiles = {texture},
    })

    -- I register my craft as an 'L' shape for fun, since it's a Luke block!
    minetest.register_craft({
        output = name,
        recipe = {
            {material, '', ''},
            {material, '', ''},
            {material, material, ''},
        },
    })
end
