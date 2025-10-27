module scripts.lua.rendertexture;

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

import scripts.lua.textures;

extern (C) nothrow int luaL_beginTextureMode(lua_State *L) {
    RenderTexture2D* target = cast(RenderTexture2D*)luaL_checkudata(L, 1, "RenderTexture");
    BeginTextureMode(*target);
    return 0;
}

extern (C) nothrow int luaL_endTextureMode(lua_State *L) {
    EndTextureMode();
    return 0;
}

extern (C) nothrow int luaL_loadRenderTexture(lua_State *L) {
    int width = cast(int)luaL_checkinteger(L, 1);
    int height = cast(int)luaL_checkinteger(L, 2);
    RenderTexture2D target = LoadRenderTexture(width, height);
    
    RenderTexture2D* targetPtr = cast(RenderTexture2D*)lua_newuserdata(L, RenderTexture2D.sizeof);
    *targetPtr = target;
    
    if (luaL_newmetatable(L, "RenderTexture")) {
    }
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_getRenderTextureTexture(lua_State *L) {
    RenderTexture2D* target = cast(RenderTexture2D*)luaL_checkudata(L, 1, "RenderTexture");
    
    Texture2D* texturePtr = cast(Texture2D*)lua_newuserdata(L, Texture2D.sizeof);
    *texturePtr = target.texture;
    
    if (luaL_newmetatable(L, "Texture")) {
    }
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_setShaderValueTexture(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 3, "Texture");
    SetShaderValueTexture(*shader, locIndex, *texture);
    return 0;
}