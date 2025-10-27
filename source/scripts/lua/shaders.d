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
    
    if (lua_gettop(L) < 3) {
        lua_pushstring(L, "loadShader requires 3 arguments: fsFileName, vsFileName, shaderIndex");
        lua_error(L);
        return 0;
    }
    
    if (!lua_isstring(L, 1) || !lua_isstring(L, 2) || !lua_isinteger(L, 3)) {
        lua_pushstring(L, "loadShader: invalid argument types");
        lua_error(L);
        return 0;
    }
    
    const char* fileName = lua_tostring(L, 1);
    const char* fileNameVs = lua_tostring(L, 2);
    int shaderIndex = cast(int)lua_tointeger(L, 3);
    
    if (shaderIndex < 0) {
        lua_pushstring(L, "Shader index cannot be negative");
        lua_error(L);
        return 0;
    }
    
    if (shaderIndex >= shaders.length) {
        try {
            shaders.length = shaderIndex + 1;
        } catch (Exception e) {
            lua_pushstring(L, "Failed to allocate shader array");
            lua_error(L);
            return 0;
        }
    }
    
    if (shaderIndex < shaders.length && shaders[shaderIndex].id != 0) {
        UnloadShader(shaders[shaderIndex]);
    }
    
    Shader newShader = LoadShader(fileNameVs, fileName);
    if (newShader.id == 0) {
        lua_pushstring(L, "Failed to load shader");
        lua_error(L);
        return 0;
    }
    
    shaders[shaderIndex] = newShader;
    return 0;
}

extern (C) nothrow int luaL_unloadShader(lua_State *L) {
    if (lua_gettop(L) < 1 || !lua_isinteger(L, 1)) {
        lua_pushstring(L, "unloadShader requires 1 integer argument: shaderIndex");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length) {
        lua_pushstring(L, "Shader index out of bounds");
        lua_error(L);
        return 0;
    }
    
    if (shaders[shaderIndex].id != 0) {
        UnloadShader(shaders[shaderIndex]);
        shaders[shaderIndex].id = 0;
    }
    
    return 0;
}

extern (C) nothrow int luaL_getShaderLocation(lua_State *L) {
    if (lua_gettop(L) < 2 || !lua_isinteger(L, 1) || !lua_isstring(L, 2)) {
        lua_pushstring(L, "getShaderLocation requires 2 arguments: shaderIndex, uniformName");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    const char* uniformName = lua_tostring(L, 2);
    int location = GetShaderLocation(shaders[shaderIndex], uniformName);
    
    if (location == -1) {
        lua_pushstring(L, "Shader uniform not found");
        lua_error(L);
        return 0;
    }
    
    lua_pushinteger(L, location);
    return 1;
}

extern (C) nothrow int luaL_setModelShader(lua_State *L) {
    if (lua_gettop(L) < 2 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2)) {
        lua_pushstring(L, "setModelShader requires 2 integer arguments: modelIndex, shaderIndex");
        lua_error(L);
        return 0;
    }
    
    int modelIndex = cast(int)lua_tointeger(L, 1);
    int shaderIndex = cast(int)lua_tointeger(L, 2);
    
    if (modelIndex < 0 || modelIndex >= models.length) {
        lua_pushstring(L, "Model index out of bounds");
        lua_error(L);
        return 0;
    }
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    Model model = models[modelIndex];
    if (model.meshCount == 0 || model.materialCount == 0) {
        lua_pushstring(L, "Invalid model");
        lua_error(L);
        return 0;
    }
    
    for (int i = 0; i < model.materialCount; i++) {
        model.materials[i].shader = shaders[shaderIndex];
    }
    
    return 0;
}

extern (C) nothrow int luaL_setShaderValueFloat(lua_State *L) {
    if (lua_gettop(L) < 3 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2) || !lua_isnumber(L, 3)) {
        lua_pushstring(L, "setShaderValueFloat requires 3 arguments: shaderIndex, locIndex, value");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    int locIndex = cast(int)lua_tointeger(L, 2);
    float value = cast(float)lua_tonumber(L, 3);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueInt(lua_State *L) {
    if (lua_gettop(L) < 3 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2) || !lua_isinteger(L, 3)) {
        lua_pushstring(L, "setShaderValueInt requires 3 arguments: shaderIndex, locIndex, value");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    int locIndex = cast(int)lua_tointeger(L, 2);
    int value = cast(int)lua_tointeger(L, 3);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_INT);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector2(lua_State *L) {
    if (lua_gettop(L) < 4 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2) || 
        !lua_isnumber(L, 3) || !lua_isnumber(L, 4)) {
        lua_pushstring(L, "setShaderValueVector2 requires 4 arguments: shaderIndex, locIndex, x, y");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    int locIndex = cast(int)lua_tointeger(L, 2);
    float x = cast(float)lua_tonumber(L, 3);
    float y = cast(float)lua_tonumber(L, 4);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    Vector2 value = Vector2(x, y);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector3(lua_State *L) {
    if (lua_gettop(L) < 5 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2) || 
        !lua_isnumber(L, 3) || !lua_isnumber(L, 4) || !lua_isnumber(L, 5)) {
        lua_pushstring(L, "setShaderValueVector3 requires 5 arguments: shaderIndex, locIndex, x, y, z");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    int locIndex = cast(int)lua_tointeger(L, 2);
    float x = cast(float)lua_tonumber(L, 3);
    float y = cast(float)lua_tonumber(L, 4);
    float z = cast(float)lua_tonumber(L, 5);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    Vector3 value = Vector3(x, y, z);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC3);
    return 0;
}

extern (C) nothrow int luaL_setShaderValueVector4(lua_State *L) {
    if (lua_gettop(L) < 6 || !lua_isinteger(L, 1) || !lua_isinteger(L, 2) || 
        !lua_isnumber(L, 3) || !lua_isnumber(L, 4) || !lua_isnumber(L, 5) || !lua_isnumber(L, 6)) {
        lua_pushstring(L, "setShaderValueVector4 requires 6 arguments: shaderIndex, locIndex, x, y, z, w");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    int locIndex = cast(int)lua_tointeger(L, 2);
    float x = cast(float)lua_tonumber(L, 3);
    float y = cast(float)lua_tonumber(L, 4);
    float z = cast(float)lua_tonumber(L, 5);
    float w = cast(float)lua_tonumber(L, 6);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    Vector4 value = Vector4(x, y, z, w);
    SetShaderValue(shaders[shaderIndex], locIndex, &value, ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    return 0;
}

extern (C) nothrow int luaL_beginShaderMode(lua_State *L) {
    if (lua_gettop(L) < 1 || !lua_isinteger(L, 1)) {
        lua_pushstring(L, "beginShaderMode requires 1 integer argument: shaderIndex");
        lua_error(L);
        return 0;
    }
    
    int shaderIndex = cast(int)lua_tointeger(L, 1);
    
    if (shaderIndex < 0 || shaderIndex >= shaders.length || shaders[shaderIndex].id == 0) {
        lua_pushstring(L, "Invalid shader index or shader not loaded");
        lua_error(L);
        return 0;
    }
    
    BeginShaderMode(shaders[shaderIndex]);
    return 0;
}

extern (C) nothrow int luaL_endShaderMode(lua_State *L) {
    EndShaderMode();
    return 0;
}