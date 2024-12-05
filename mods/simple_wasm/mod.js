function utf8ToString(mem, pos) {
    let s = "";
    for (i = pos; mem[i]; i++) {
        s += String.fromCharCode(mem[i]);
    }
    return s;
}
 
var buffer = new Uint8Array(%wbC:\Users\elija\Documents\GitHub\minetest\mods\simple_wasm\mod.wasmwb%);
var m = new WebAssembly.Instance(new WebAssembly.Module(buffer));
var memArray = new Uint8Array(m.exports.memory.buffer);
var ex = m.exports;
 
var modInfo = {
    name: utf8ToString(memArray, ex.getName()),
    description: utf8ToString(memArray, ex.getDescription()),
    texture: utf8ToString(memArray, ex.getTexture()),
    material: utf8ToString(memArray, ex.getMaterial()),
};
 
function getMod(mod) {
    return mod;
};
 
getMod(modInfo);