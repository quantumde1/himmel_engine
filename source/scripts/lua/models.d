module scripts.lua.models;

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

extern (C) nothrow int luaL_loadModel(lua_State *L) {
    const char* fileName = luaL_checkstring(L, 1);
    
    Model* modelPtr = cast(Model*)lua_newuserdata(L, Model.sizeof);
    
    Model loadedModel = LoadModel(fileName);
    *modelPtr = loadedModel;
    
    if (luaL_newmetatable(L, "Model")) {
    }
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_unloadModel(lua_State *L) {
    Model* model = cast(Model*)luaL_checkudata(L, 1, "Model");
    debugWriteln("model meshCount: ", model.meshCount);
    if (model.meshCount != 0) {
        UnloadModel(*model);
    } else {
        debugWriteln("model already unloaded or invalid");
    }
    return 0;
}

extern (C) nothrow int luaL_drawModel(lua_State *L) {
    Model* model = cast(Model*)luaL_checkudata(L, 1, "Model");
    float x = luaL_checknumber(L, 2);
    float y = luaL_checknumber(L, 3);
    float z = luaL_checknumber(L, 4);
    float rotation = luaL_optnumber(L, 5, 0);
    float scale = luaL_optnumber(L, 6, 1);
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
    DrawModelEx(
        *model,
        Vector3(x, y, z),
        Vector3(0.0f, 1.0f, 0.0f),
        rotation,
        Vector3(scale, scale, scale),
        color
    );
    return 0;
}

extern (C) nothrow int luaL_loadModelAnimations(lua_State *L) {
    modelAnimations = LoadModelAnimations(luaL_checkstring(L, 1), &animsCount);
    return 0;
}

extern (C) nothrow int luaL_updateModelAnimation(lua_State *L) {
        ModelAnimation anim = modelAnimations[cast(int)luaL_checkinteger(L, 2)];
        int speedMultipler;
        if (lua_gettop(L) == 3) {
            speedMultipler = cast(int)luaL_checkinteger(L, 3);
        } else {
            speedMultipler = 1;
        }
        animationCurrentFrame = (animationCurrentFrame + speedMultipler)%anim.frameCount;
        Model *model = cast(Model*)luaL_checkudata(L, 1, "Model");
        UpdateModelAnimation(*model, anim, animationCurrentFrame);
        return 0;
}

extern (C) nothrow int luaL_resetModelAnimation(lua_State *L) {
    animationCurrentFrame = 0;
    return 0;
}