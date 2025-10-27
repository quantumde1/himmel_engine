module scripts.lua.shaders;

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

extern (C) nothrow int luaL_loadShader(lua_State *L) {
    debugWriteln("Loading custom shader");
    const char* fileName = luaL_checkstring(L, 1);
    const char* fileNameVs = luaL_checkstring(L, 2);
    int shaderIndex = cast(int)luaL_checkinteger(L, 3);
    if (shaderIndex >= shaders.length) {
        shaders.length = shaderIndex + 1;
    }
    if (shaders.length < shaders.length) {
        shaders.length = shaders.length;
    }
    if (shaderIndex < shaders.length && shaders[shaderIndex].id != 0) {
        UnloadShader(shaders[shaderIndex]);
    }
    shaders[shaderIndex] = LoadShader(fileNameVs, fileName);
    return 1;
}

extern (C) nothrow int luaL_unloadShader(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    UnloadShader(shaders[shaderIndex]);
    return 0;
}

extern (C) nothrow int luaL_getShaderLocation(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    char* smth = cast(char*)luaL_checkstring(L, 2);
    lua_pushinteger(L, GetShaderLocation(shaders[shaderIndex], smth));
    return 1;
}

extern (C) nothrow int luaL_setModelShader(lua_State *L) {
    int modelIndex = cast(int)luaL_checkinteger(L, 1);
    int shaderIndex = cast(int)luaL_checkinteger(L, 2);
    for (int i = 0; i <= models[modelIndex].materialCount; i++) {
        models[modelIndex].materials[i].shader = shaders[shaderIndex];
    }
    return 0;
}

extern (C) nothrow int luaL_setShaderValueFloat(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float value = cast(float)luaL_checknumber(L, 3);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueInt(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    int value = cast(int)luaL_checkinteger(L, 3);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_INT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector2(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    Vector2 value = Vector2(x, y);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector3(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    float z = cast(float)luaL_checknumber(L, 5);
    Vector3 value = Vector3(x, y, z);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector4(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    float z = cast(float)luaL_checknumber(L, 5);
    float w = cast(float)luaL_checknumber(L, 6);
    Vector4 value = Vector4(x, y, z, w);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    return 0;
}

// Post-processing shader functions
extern (C) nothrow int luaL_beginShaderMode(lua_State *L) {
    int shaderIndex = cast(int)luaL_checkinteger(L, 1);
    BeginShaderMode(shaders[shaderIndex]);
    return 0;
}

extern (C) nothrow int luaL_endShaderMode(lua_State *L) {
    EndShaderMode();
    return 0;
}