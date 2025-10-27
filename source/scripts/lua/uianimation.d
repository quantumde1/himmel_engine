module scripts.lua.uianimation;

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

extern (C) nothrow int luaL_loadUIAnimation(lua_State *L) {
    try {
        //loads from uifx folder HPFF files, in which png textures are stored
        framesUI = loadAnimationFramesUI(to!string(luaL_checkstring(L, 1)), to!string(luaL_checkstring(L, 2)));
        if (lua_gettop(L) == 3) {
            frameDuration = luaL_checknumber(L, 3);
            debug debugWriteln("frameDuration: ", frameDuration);
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_playUIAnimation(lua_State *L) {
    debug debugWriteln("Animation UI start");
    try {
        if (lua_gettop(L) == 0) playAnimation = true;
        else {
            debugWriteln("animationAlpha before reconfig: ", animationAlpha);
            animationAlpha = luaL_checkinteger(L, 1).to!ubyte;
            debugWriteln("animationAlpha after reconfig: ", animationAlpha);
            playAnimation = true;
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopUIAnimation(lua_State *L) {
    playAnimation = false;
    debug debugWriteln("Animation UI stop");
    frameDuration = 0.016f;
    currentFrame = 0;
    return 0;
}

extern (C) nothrow int luaL_unloadUIAnimation(lua_State *L) {
    try {
        for (int i = 0; i < framesUI.length; i++) {
            UnloadTexture(framesUI[i]);
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}