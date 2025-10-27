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
    
    Shader* shaderPtr = cast(Shader*)lua_newuserdata(L, Shader.sizeof);
    
    Shader loadedShader = LoadShader(fileNameVs, fileName);
    *shaderPtr = loadedShader;
    
    debugWriteln("Shader loaded successfully, ID: ", shaderPtr.id);
    
    if (luaL_newmetatable(L, "Shader")) {
    }
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_unloadShader(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    debugWriteln("shader id: ", shader.id);
    if (shader.id != 0) {
        debugWriteln("unloading custom shader ID: ", shader.id);
        UnloadShader(*shader);
        shader.id = 0;
    } else {
        debugWriteln("shader already unloaded or invalid");
    }
    return 0;
}

extern (C) nothrow int luaL_getShaderLocation(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    char* smth = cast(char*)luaL_checkstring(L, 2);
    lua_pushinteger(L, GetShaderLocation(*shader, smth));
    return 1;
}

extern (C) nothrow int luaL_setModelShader(lua_State *L) {
    Model* model = cast(Model*)luaL_checkudata(L, 1, "Model");
    Shader* shader = cast(Shader*)luaL_checkudata(L, 2, "Shader");
    for (int i = 0; i <= model.materialCount; i++) {
        model.materials[i].shader = *shader;
    }
    return 0;
}

extern (C) nothrow int luaL_setShaderValueFloat(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float value = cast(float)luaL_checknumber(L, 3);
    SetShaderValue(*shader, locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueInt(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    int value = cast(int)luaL_checkinteger(L, 3);
    SetShaderValue(*shader, locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_INT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector2(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    Vector2 value = Vector2(x, y);
    SetShaderValue(*shader, locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector3(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    float z = cast(float)luaL_checknumber(L, 5);
    Vector3 value = Vector3(x, y, z);
    SetShaderValue(*shader, locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector4(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    int locIndex = cast(int)luaL_checkinteger(L, 2);
    float x = cast(float)luaL_checknumber(L, 3);
    float y = cast(float)luaL_checknumber(L, 4);
    float z = cast(float)luaL_checknumber(L, 5);
    float w = cast(float)luaL_checknumber(L, 6);
    Vector4 value = Vector4(x, y, z, w);
    SetShaderValue(*shader, locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    return 0;
}

// Post-processing shader functions
extern (C) nothrow int luaL_beginShaderMode(lua_State *L) {
    Shader* shader = cast(Shader*)luaL_checkudata(L, 1, "Shader");
    BeginShaderMode(*shader);
    return 0;
}

extern (C) nothrow int luaL_endShaderMode(lua_State *L) {
    EndShaderMode();
    return 0;
}