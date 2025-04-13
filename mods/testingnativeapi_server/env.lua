Path = "C:\\minetest\\worlds\\mapgentest\\map.sqlite"
LuaMediaPath = "C:\\Users\\ellio\\Downloads\\luatestimage.png"
NativeMediaPath = "C:\\Users\\ellio\\Downloads\\nativetestimage.png"
MediaCachePath = "C:\\minetest\\cache\\media\\"
AuthTablePath = "C:\\minetest\\clientmods\\testingnativeapi_client\\textures\\auth.sqlite"

CompareTables = function (table1, table2)
    local identical = true
    for i, v in pairs(table1) do
        if table2[i] ~= v then identical = false 
            core.chat_send_all(i)
        end
    end
    for i, v in pairs(table2) do
        if table1[i] ~= v then identical = false
            core.chat_send_all(i)
         end
    end
    return identical
end

TableContains = function (table, element)
    local contains = false
    for _, v in pairs(table) do
        if v == element then contains = true end
    end
    return contains
end

Log = function (data)
    local f = io.open("logfile.txt", "a")
    f:write(dump(data).."\n")
end