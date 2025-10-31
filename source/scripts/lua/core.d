// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.lua.core;

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

import scripts.lua.audio;
import scripts.lua.collision;
import scripts.lua.geometry;
import scripts.lua.input;
import scripts.lua.models;
import scripts.lua.shaders;
import scripts.lua.system;
import scripts.lua.text;
import scripts.lua.textures;
import scripts.lua.uianimation;
import scripts.lua.video;
import scripts.lua.visualnovel;

extern (C) nothrow void luaL_loader(lua_State* L)
{
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "isDialogExecuted", &luaL_isDialogExecuted);
    lua_register(L, "getAnswerValue", &luaL_getAnswerValue);
    lua_register(L, "loadAnimationUI", &luaL_loadUIAnimation);
    lua_register(L, "playAnimationUI", &luaL_playUIAnimation);
    lua_register(L, "stopAnimationUI", &luaL_stopUIAnimation);
    lua_register(L, "unloadAnimationUI", &luaL_unloadUIAnimation);
    lua_register(L, "setDialogBoxBackground", &luaL_setDialogBoxBackground);
    lua_register(L, "setDialogEndIndicator", &luaL_setDialogBoxEndIndicatorTexture);
    lua_register(L, "playVideo", &luaL_playVideo);
    lua_register(L, "loadMusic", &luaL_loadMusic);
    lua_register(L, "playMusic", &luaL_playMusic);
    lua_register(L, "stopMusic", &luaL_stopMusic);
    lua_register(L, "unloadMusic", &luaL_unloadMusic);
    lua_register(L, "setMusicVolume", &luaL_setMusicVolume);
    lua_register(L, "playSfx", &luaL_playSfx);
    lua_register(L, "stopSfx", &luaL_stopSfx);
    lua_register(L, "loadCharacter", &luaL_loadCharacter);
    lua_register(L, "drawCharacter", &luaL_drawCharacter);
    lua_register(L, "stopDrawCharacter", &luaL_stopDrawCharacter);
    lua_register(L, "unloadCharacter", &luaL_unloadCharacter);
    lua_register(L, "loadBackground", &luaL_loadBackground);
    lua_register(L, "drawBackground", &luaL_drawBackground);
    lua_register(L, "stopDrawBackground", &luaL_stopDrawBackground);
    lua_register(L, "unloadBackground", &luaL_unloadBackground);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "getScreenHeight", &luaL_getScreenHeight);
    lua_register(L, "getScreenWidth", &luaL_getScreenWidth);
    lua_register(L, "isKeyPressed", &luaL_isKeyPressed);
    lua_register(L, "isKeyDown", &luaL_isKeyDown);
    lua_register(L, "isMouseButtonPressed", &luaL_isMouseButtonPressed);
    lua_register(L, "isMouseButtonDown", &luaL_isMouseButtonDown);
    lua_register(L, "getMouseX", &luaL_getMouseX);
    lua_register(L, "getMouseY", &luaL_getMouseY);
    lua_register(L, "setGameState", &luaL_setGameState);
    lua_register(L, "setCamera", &luaL_setCamera);
    lua_register(L, "loadModelAnimations", &luaL_loadModelAnimations);
    lua_register(L, "updateModelAnimation", &luaL_updateModelAnimation);
    lua_register(L, "resetModelAnimation", &luaL_resetModelAnimation);
    lua_register(L, "placeCollision", &luaL_placeCollision);
    lua_register(L, "moveCollision", &luaL_moveCollision);
    lua_register(L, "removeCollision", &luaL_removeCollision);
    lua_register(L, "playerCollisionIndex", &luaL_setPlayerCollisionIndex);
    lua_register(L, "drawCollision", &luaL_drawCollisionWires);
    lua_register(L, "checkAllCollision", &luaL_checkCollision);
    lua_register(L, "checkSpecificCollision", &luaL_checkCollisionIndex);
    
    //raylib direct bindings
    lua_register(L, "drawRectangle", &luaL_drawRect);
    lua_register(L, "unloadFont", &luaL_unloadFont);
    lua_register(L, "loadFont", &luaL_loadFont);
    lua_register(L, "getTime", &luaL_getTime);
    lua_register(L, "getDeltaTime", &luaL_getDeltaTime);
    lua_register(L, "loadTexture", &luaL_loadTexture);
    lua_register(L, "drawTexture", &luaL_drawTexture);
    lua_register(L, "drawTextureEx", &luaL_drawTextureEx);
    lua_register(L, "unloadTexture", &luaL_unloadTexture);
    lua_register(L, "drawText", &luaL_drawText);
    lua_register(L, "measureTextX", &luaL_measureTextX);
    lua_register(L, "measureTextY", &luaL_measureTextY);
    lua_register(L, "getTextureWidth", &luaL_getTextureWidth);
    lua_register(L, "getTextureHeight", &luaL_getTextureHeight);
    lua_register(L, "loadModel", &luaL_loadModel);
    lua_register(L, "drawModel", &luaL_drawModel);
    lua_register(L, "unloadModel", &luaL_unloadModel);
    lua_register(L, "showCursor", &luaL_showCursor);
    lua_register(L, "hideCursor", &luaL_hideCursor);
    lua_register(L, "setMousePosition", &luaL_setMousePosition);
    lua_register(L, "drawFPS", &luaL_drawFPS);
    lua_register(L, "clearBackground", &luaL_clearBackground);
    // Shader bindings
    lua_register(L, "loadShader", &luaL_loadShader);
    lua_register(L, "unloadShader", &luaL_unloadShader);
    lua_register(L, "getShaderLocation", &luaL_getShaderLocation);
    lua_register(L, "setModelShader", &luaL_setModelShader);
    lua_register(L, "setShaderValueFloat", &luaL_setShaderValueFloat);
    lua_register(L, "setShaderValueInt", &luaL_setShaderValueInt);
    lua_register(L, "setShaderValueVector2", &luaL_setShaderValueVector2);
    lua_register(L, "setShaderValueVector3", &luaL_setShaderValueVector3);
    lua_register(L, "setShaderValueVector4", &luaL_setShaderValueVector4);

    // Shader mode
    lua_register(L, "beginShaderMode", &luaL_beginShaderMode);
    lua_register(L, "endShaderMode", &luaL_endShaderMode);

    // Utils
    lua_register(L, "getFPS", &luaL_getFPS);
    lua_register(L, "getFrameTime", &luaL_getFrameTime);

    //compat
    lua_register(L, "setFont", &luaL_loadFont);

    lua_register(L, "print", &luaL_print);
    debugWriteln("strict mode enabled");
    const char* strict_lua =
    `local mt = {
        __index = function(_, name)
            error("attempt to call undefined function: " .. tostring(name), 2)
        end
    }
    setmetatable(_G, mt)`;

    if (luaL_dostring(L, strict_lua) != LUA_OK) {
        debugWriteln("Failed to set strict mode: ", to!string(lua_tostring(L, -1)));
        lua_pop(L, 1); // Pop the error message
    }
}

int luaInit(string luaExec)
{
    debugWriteln("loading Lua");
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_loader(L);
    debugWriteln("Executing next Lua file: ", luaExec);
    if (std.file.exists(luaExec) == false) {
        debugWriteln("Script file not found! Exiting.");
        return EngineExitCodes.EXIT_FILE_NOT_FOUND;
    }
    if (luaL_dofile(L, toStringz(luaExec)) != LUA_OK) {
        debugWriteln("Lua error: ", to!string(lua_tostring(L, -1)));
        return EngineExitCodes.EXIT_SCRIPT_ERROR;
    }
    return EngineExitCodes.EXIT_OK;
}

void luaEventLoopPost2D()
{
    lua_getglobal(L, "EventLoop2D");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        debug debugWriteln("Error in EventLoop2D: ", to!string(lua_tostring(L, -1)));
    }
    lua_pop(L, 0);
}

void luaEventLoopPre2D()
{
    lua_getglobal(L, "EventLoopPre2D");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        debug debugWriteln("Error in EventLoop2D: ", to!string(lua_tostring(L, -1)));
    }
    lua_pop(L, 0);
}

void luaEventLoop3D()
{
    lua_getglobal(L, "EventLoop3D");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        debug debugWriteln("Error in EventLoop3D: ", to!string(lua_tostring(L, -1)));
    }
    lua_pop(L, 0);
}