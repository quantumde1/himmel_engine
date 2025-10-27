module scripts.lua.textures;

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

extern (C) nothrow int luaL_loadTexture(lua_State *L) {
    const char* fileName = luaL_checkstring(L, 1);
    Texture texture = LoadTexture(fileName);
    
    Texture* texturePtr = cast(Texture*)lua_newuserdata(L, Texture.sizeof);
    *texturePtr = texture;
    
    if (luaL_newmetatable(L, "Texture")) {
    }
    //SetTextureFilter(texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_unloadTexture(lua_State *L) {
    Texture* texture = cast(Texture*)luaL_checkudata(L, 1, "Texture");
    debugWriteln("texture id: ", texture.id);
    if (texture.id != 0) {
        UnloadTexture(*texture);
    } else {
        debugWriteln("texture already unloaded or invalid");
    }
    return 0;
}

extern (C) nothrow int luaL_drawTexture(lua_State *L) {
    Texture* texture = cast(Texture*)luaL_checkudata(L, 1, "Texture");
    int x = cast(int)luaL_checkinteger(L, 2);
    int y = cast(int)luaL_checkinteger(L, 3);
    float scale = luaL_checknumber(L, 4)*variables.scale;
    Color color = Colors.WHITE;
    
    if (lua_gettop(L) >= 5 && lua_istable(L, 5)) {
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
    
    DrawTextureEx(*texture, Vector2(x, y), 0.0f, scale, color);
    return 0;
}

extern (C) nothrow int luaL_getTextureWidth(lua_State *L) {
    Texture* texture = cast(Texture*)luaL_checkudata(L, 1, "Texture");
    lua_pushnumber(L, texture.width*variables.scale);
    return 1;
}

extern (C) nothrow int luaL_getTextureHeight(lua_State *L) {
    Texture* texture = cast(Texture*)luaL_checkudata(L, 1, "Texture");
    lua_pushnumber(L, texture.height*variables.scale);
    return 1;
}

extern (C) nothrow int luaL_drawTextureEx(lua_State *L) {
    Texture* texture = cast(Texture*)luaL_checkudata(L, 1, "Texture");
    float x = luaL_checknumber(L, 2);
    float y = luaL_checknumber(L, 3);
    float rotation = luaL_optnumber(L, 4, 0);
    float scale = luaL_optnumber(L, 5, 1);
    Color color = Colors.WHITE;
    if (lua_istable(L, 6)) {
        lua_getfield(L, 6, "r");
        color.r = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 6, "g");
        color.g = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 6, "b");
        color.b = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 6, "a");
        color.a = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    DrawTextureEx(*texture, Vector2(x, y), rotation, scale*variables.scale, color);
    
    return 0;
}