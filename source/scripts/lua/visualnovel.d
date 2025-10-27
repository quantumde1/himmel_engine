module scripts.lua.visualnovel;

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

extern (C) nothrow int luaL_dialogBox(lua_State* L)
{
    showDialog = true;

    // parse table with text pages
    luaL_checktype(L, 1, LUA_TTABLE);
    int textTableLength = cast(int) lua_objlen(L, 1);
    messageGlobal = new string[](textTableLength); 

    foreach (i; 0..textTableLength) {
        lua_rawgeti(L, 1, i + 1);
        messageGlobal[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }

    //parse table with choices
    luaL_checktype(L, 2, LUA_TTABLE);
    int choicesLength = cast(int) lua_objlen(L, 2);
    choices = new string[choicesLength];
    foreach (i; 0..choicesLength)
    {
        lua_rawgeti(L, 2, i + 1);
        choices[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    //if provided, get page on which choices must be shown
    if (lua_gettop(L) >= 3) {
        choicePage = cast(int)luaL_checkinteger(L, 3);
    }

    if (lua_gettop(L) >= 4 && !lua_istable(L, 4)) {
        typingSpeed = cast(float) luaL_checknumber(L, 4);
    }
    return 0;
}

extern (C) nothrow int luaL_getAnswerValue(lua_State* L)
{
    lua_pushinteger(L, selectedChoice);
    return 1;
}

extern (C) nothrow int luaL_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, showDialog);
    return 1;
}

/* background drawing and loading */

extern (C) nothrow int luaL_loadBackground(lua_State* L)
{
    try
    {
        int count = cast(int)luaL_checkinteger(L, 2);
        if (count >= backgroundTextures.length) {
            backgroundTextures.length = count + 1;
        }
        if (backgroundTextures[count].texture.id != 0) {
            UnloadTexture(backgroundTextures[count].texture);
        }
        char* filename = cast(char*)luaL_checkstring(L, 1);
        backgroundTextures[count].texture = LoadTexture(filename);
        SetTextureFilter(backgroundTextures[count].texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_drawBackground(lua_State* L)
{
    try
    {
        int count = cast(int)luaL_checkinteger(L, 4);
        debugWriteln(backgroundTextures[count]);
        backgroundTextures[count].height = backgroundTextures[count].texture.height;
        if (backgroundTextures.length < count) {
            backgroundTextures.length = backgroundTextures.length;
        }
        backgroundTextures[count].width = backgroundTextures[count].texture.width;
        backgroundTextures[count].x = luaL_checknumber(L, 1);
        backgroundTextures[count].y = luaL_checknumber(L, 2);
        backgroundTextures[count].scale = luaL_checknumber(L, 3) * scale;
        backgroundTextures[count].drawTexture = true;
        debugWriteln(backgroundTextures[count]);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopDrawBackground(lua_State* L)
{
    try
    {
        int count = cast(int)luaL_checkinteger(L, 1);
        if (count >= backgroundTextures.length) {
            debugWriteln("stop draw not loaded background unavailable");
        } else {
            backgroundTextures[count].drawTexture = false;
        }
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_unloadBackground(lua_State* L)
{
    int count = cast(int)luaL_checkinteger(L, 1);
    if (count >= backgroundTextures.length) {
        debugWriteln("Unloading non-loaded background unavailable");
    } else {
        backgroundTextures[count].drawTexture = false;
        UnloadTexture(backgroundTextures[count].texture);
    }
    return 0;
}

/* character textures */

extern (C) nothrow int luaL_loadCharacter(lua_State *L) {
    try
    {
        
        int count = cast(int) luaL_checkinteger(L, 2);

        if (count >= characterTextures.length) {
            characterTextures.length = count + 1;
        }
        if (characterTextures.length < characterTextures.length) {
            characterTextures.length = characterTextures.length;
        }
        if (count < characterTextures.length && characterTextures[count].texture.id != 0) {
            UnloadTexture(characterTextures[count].texture);
        }
        characterTextures[count].texture = LoadTexture(luaL_checkstring(L, 1));
        //SetTextureFilter(characterTextures[count].texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
        characterTextures[count].width = characterTextures[count].texture.width;
        characterTextures[count].height = characterTextures[count].texture.height;
        characterTextures[count].drawTexture = false;
    }
    catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_drawCharacter(lua_State* L)
{
    try {
        //configuring needed parameters in characterTextures like coordinates, scale and drawTexture(its a boolean value which checks need this texture to be drawn or not)
        int count = to!int(luaL_checkinteger(L, 4));
        characterTextures[count].scale = luaL_checknumber(L, 3) * scale;
        characterTextures[count].y = cast(int) luaL_checknumber(L, 2);
        characterTextures[count].x = cast(int) luaL_checknumber(L, 1);
        characterTextures[count].drawTexture = true;
        characterTextures[count].justDrawn = true;
        if (lua_gettop(L) == 5) {
            lua_getfield(L, 5, "r");
            characterTextures[count].color.r = cast(ubyte)lua_tointeger(L, -1);
            lua_pop(L, 1);
            
            lua_getfield(L, 5, "g");
            characterTextures[count].color.g = cast(ubyte)lua_tointeger(L, -1);
            lua_pop(L, 1);
            
            lua_getfield(L, 5, "b");
            characterTextures[count].color.b = cast(ubyte)lua_tointeger(L, -1);
            lua_pop(L, 1);
            
            lua_getfield(L, 5, "a");
            //if empty, reset to default
            if (!lua_isnil(L, -1)) {
                characterTextures[count].color.a = cast(ubyte)lua_tointeger(L, -1);
            }
            lua_pop(L, 1);
        } else {
            characterTextures[count].color = Colors.WHITE;
        }
        debugWriteln("Count: ", count, " drawTexture cond: ", characterTextures[count].drawTexture);
        debugWriteln("arguments count: ", lua_gettop(L));
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopDrawCharacter(lua_State* L)
{
    int count = cast(int) luaL_checkinteger(L, 1);
    if (count >= characterTextures.length) {
        debugWriteln("error stop draw not loaded character");
    } else {
        characterTextures[count].drawTexture = false;
    }
    return 0;
}

extern (C) nothrow int luaL_unloadCharacter(lua_State *L) {
    int count = cast(int) luaL_checkinteger(L, 1);
    if (count >= characterTextures.length) {
        debugWriteln("error unloading not loaded character");
    } else {
        characterTextures[count].drawTexture = false;
        UnloadTexture(characterTextures[count].texture);
    }
    return 0;
}

extern (C) nothrow int luaL_setDialogBoxBackground(lua_State *L) {
    string filename = luaL_checkstring(L, 1).to!string;
    debug debugWriteln("Set dialog background to: ", filename);
    UnloadTexture(dialogBackgroundTex);
    dialogBackgroundTex = Texture2D();
    dialogBackgroundTex = LoadTexture(filename.toStringz());
    return 0;
}

extern (C) nothrow int luaL_setDialogBoxEndIndicatorTexture(lua_State *L) {
    char* filename = cast(char*)luaL_checkstring(L, 1);
    UnloadTexture(circle);
    circle = Texture2D();
    circle = LoadTexture(filename);
    return 0;
}