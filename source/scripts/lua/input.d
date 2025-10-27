module scripts.lua.input;

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

float lastKeyPressTime = 0.0;
immutable float keyPressCooldown = 0.001;

extern (C) nothrow int luaL_isKeyPressed(lua_State* L)
{
    try
    {
        int keyCode = cast(int)luaL_checkinteger(L, 1);
        bool isPressed = IsKeyPressed(keyCode).to!bool;

        double currentTime = GetTime();
        if (isPressed && (currentTime - lastKeyPressTime) < keyPressCooldown)
        {
            lua_pushboolean(L, false);
        }
        else if (isPressed)
        {
            lastKeyPressTime = currentTime;
            lua_pushboolean(L, true);
        }
        else
        {
            lua_pushboolean(L, false);
        }

        return 1;
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
        lua_pushboolean(L, false);
        return 1;
    }
}

extern (C) nothrow int luaL_isKeyDown(lua_State *L) {
    return IsKeyDown(cast(int)luaL_checkinteger(L, 1));
}

extern (C) nothrow int luaL_isMouseButtonPressed(lua_State* L)
{
    try
    {
        int keyCode = cast(int)luaL_checkinteger(L, 1);
        bool isPressed = IsMouseButtonPressed(keyCode);

        double currentTime = GetTime();
        if (isPressed && (currentTime - lastKeyPressTime) < keyPressCooldown)
        {
            lua_pushboolean(L, false);
        }
        else if (isPressed)
        {
            lastKeyPressTime = currentTime;
            lua_pushboolean(L, true);
        }
        else
        {
            lua_pushboolean(L, false);
        }

        return 1;
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
        lua_pushboolean(L, false);
        return 1;
    }
}

extern (C) nothrow int luaL_isMouseButtonDown(lua_State* L)
{
    try
    {
        int keyCode = cast(int)luaL_checkinteger(L, 1);
        bool isPressed = IsMouseButtonDown(keyCode);

        double currentTime = GetTime();
        if (isPressed && (currentTime - lastKeyPressTime) < keyPressCooldown)
        {
            lua_pushboolean(L, false);
        }
        else if (isPressed)
        {
            lastKeyPressTime = currentTime;
            lua_pushboolean(L, true);
        }
        else
        {
            lua_pushboolean(L, false);
        }

        return 1;
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
        lua_pushboolean(L, false);
        return 1;
    }
}

extern (C) nothrow int luaL_getMouseX(lua_State *L) {
    lua_pushnumber(L, GetMousePosition.x);
    return 1;
}

extern (C) nothrow int luaL_getMouseY(lua_State *L) {
    lua_pushnumber(L, GetMousePosition.y);
    return 1;
}