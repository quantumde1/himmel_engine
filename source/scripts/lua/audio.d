module scripts.lua.audio;

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

extern (C) nothrow int luaL_loadMusic(lua_State* L)
{
    try
    {
        char* musicPath = cast(char*)luaL_checkstring(L, 1);
        music = LoadMusicStream(musicPath);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_playMusic(lua_State* L)
{
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_stopMusic(lua_State* L)
{
    StopMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_unloadMusic(lua_State* L)
{
    UnloadMusicStream(music);
    music = Music();
    return 0;
}

extern (C) nothrow int luaL_setMusicVolume(lua_State *L) {
    SetMusicVolume(music, luaL_checknumber(L, 1));
    return 0;
}

extern (C) nothrow int luaL_playSfx(lua_State *L) {
    try {
    playSfx(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopSfx(lua_State *L) {
    StopSound(sfx);
    return 0;
}