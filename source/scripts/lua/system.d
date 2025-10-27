module scripts.lua.system;

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

extern (C) nothrow int luaL_print(lua_State *L) {
    try {
        string lineToPrint = to!string(luaL_checkstring(L, 1));
        debugWriteln(lineToPrint);
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_showCursor(lua_State *L) {
    ShowCursor();
    return 0;
}

extern (C) nothrow int luaL_hideCursor(lua_State *L) {
    HideCursor();
    return 0;
}

extern (C) nothrow int luaL_setMousePosition(lua_State *L) {
    SetMousePosition(cast(int)luaL_checkinteger(L, 1), cast(int)luaL_checkinteger(L, 2));
    return 0;
}

extern (C) nothrow int luaL_drawFPS(lua_State *L) {
    DrawFPS(cast(int)luaL_checkinteger(L, 1), cast(int)luaL_checkinteger(L, 2));
    return 0;
}

extern (C) nothrow int luaL_getFPS(lua_State *L) {
    lua_pushinteger(L, GetFPS());
    return 1;
}

extern (C) nothrow int luaL_getFrameTime(lua_State *L) {
    lua_pushnumber(L, GetFrameTime());
    return 1;
}

extern (C) nothrow int luaL_getScreenWidth(lua_State* L)
{
    lua_pushinteger(L, GetScreenWidth());
    return 1;
}

extern (C) nothrow int luaL_getScreenHeight(lua_State* L)
{
    lua_pushinteger(L, GetScreenHeight());
    return 1;
}

extern (C) nothrow int luaL_unloadFont(lua_State *L) {
    UnloadFont(textFont);
    return 0;
}

extern (C) nothrow int luaL_loadFont(lua_State* L)
{
    const char* x = luaL_checkstring(L, 1);
    debugWriteln("Setting custom font: ", x.to!string);
    int[512] codepoints = 0;
    //configuring both cyrillic and latin fonts if available
    foreach (i; 0 .. 95)
    {
        codepoints[i] = 32 + i;
    }
    foreach (i; 0 .. 255)
    {
        codepoints[96 + i] = 0x400 + i;
    }
    int fontSize = max(10, cast(int)(40 * scale));
    textFont = LoadFontEx(x, fontSize, null, 0);
    return 0;
}

extern (C) nothrow int luaL_getTime(lua_State* L)
{
    //getTime() returns current time.
    lua_pushnumber(L, GetTime());
    return 1;
}

extern (C) nothrow int luaL_getDeltaTime(lua_State* L)
{
    //getDeltaTime
    lua_pushnumber(L, GetFrameTime());
    return 1;
}

extern (C) nothrow int luaL_loadScript(lua_State* L)
{
    try
    {
        luaExec = luaL_checkstring(L, 1).to!string;
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    luaReload = true;
    return 0;
}

extern (C) nothrow int luaL_setGameState(lua_State *L) {
    currentGameState = cast(int)luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int luaL_setCamera(lua_State *L) {
    camera.position = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    camera.target = Vector3(
        luaL_checknumber(L, 4),
        luaL_checknumber(L, 5),
        luaL_checknumber(L, 6)
    );
    return 0;
}

extern (C) nothrow int luaL_unloadCircle(lua_State *L) {
    UnloadTexture(circle);
    debugWriteln("unloaded circle");
    return 0;
}

extern (C) nothrow int luaL_unloadDialogBackground(lua_State *L) {
    UnloadTexture(dialogBackgroundTex);
    debugWriteln("unloaded dialog background");
    return 0;
}