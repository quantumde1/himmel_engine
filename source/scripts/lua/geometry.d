module scripts.lua.geometry;

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

extern (C) nothrow int luaL_drawRect(lua_State *L) {
    DrawRectangle(cast(int)luaL_checkinteger(L, 1), cast(int)luaL_checkinteger(L, 2), cast(int)luaL_checkinteger(L, 3), cast(int)luaL_checkinteger(L, 4), Colors.WHITE);
    return 0;
}