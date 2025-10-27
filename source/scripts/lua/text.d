module scripts.lua.text;

import bindbc.lua;
import raylib;
import variables;
import graphics.effects;
import std.conv;
import system.abstraction;
import system.config;
import std.string;
import std.algorithm;
import system.init;
import graphics.playback;
import std.file;
import graphics.collision;
import audio.sfx;

extern (C) nothrow int luaL_drawText(lua_State *L) {
    const char* text = luaL_checkstring(L, 1);
    int x = cast(int)luaL_checkinteger(L, 2);
    int y = cast(int)luaL_checkinteger(L, 3);
    int fontSize = cast(int)luaL_optinteger(L, 4, 20);
    Color color = Colors.WHITE;
    if (lua_istable(L, 5)) {
        lua_getfield(L, 5, "r");
        color.r = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 5, "g");
        color.g = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 5, "b");
        color.b = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 5, "a");
        color.a = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    
    DrawTextEx(textFont, text, Vector2(x, y), fontSize, 1.0f, color);
    
    return 0;
}

extern (C) nothrow int luaL_measureTextX(lua_State *L) {
    lua_pushinteger(L, cast(int)MeasureTextEx(textFont, luaL_checkstring(L, 1), cast(int)luaL_checkinteger(L, 2), 1.0f).x);
    return 1;
}

extern (C) nothrow int luaL_measureTextY(lua_State *L) {
    lua_pushinteger(L, cast(int)MeasureTextEx(textFont, luaL_checkstring(L, 1), cast(int)luaL_checkinteger(L, 2), 1.0f).y);
    return 1;
}