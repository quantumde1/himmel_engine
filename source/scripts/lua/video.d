module scripts.lua.video;

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

extern (C) nothrow int luaL_playVideo(lua_State* L)
{
    try
    {
        videoFinished = false;
        playVideo(luaL_checkstring(L, 1).to!string);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}