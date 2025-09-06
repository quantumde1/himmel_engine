// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.lua;

import bindbc.lua;
import raylib;
import variables;
import graphics.effects;
import std.conv;
import system.abstraction;
import system.config;
import std.string;
import std.algorithm;
import graphics.engine;
import graphics.playback;
import std.file;

/* 
 * This module provides Lua bindings for various engine functionalities.
 * Functions are built on top of engine built-in functions for execution from scripts.
 * Not all engine functions usable for scripting are yet implemented.
*/

/* text window */

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
        SetTextureFilter(characterTextures[count].texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
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

/* music and video */

extern (C) nothrow int luaL_loadMusic(lua_State* L)
{
    try
    {
        char* musicPath = cast(char*)luaL_checkstring(L, 1);
        music = LoadMusicStream(musicPath);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_playMusic(lua_State* L)
{
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_stopMusic(lua_State* L)
{
    StopMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_unloadMusic(lua_State* L)
{
    UnloadMusicStream(music);
    music = Music();
    return 0;
}

extern (C) nothrow int luaL_playSfx(lua_State *L) {
    try {
    playSfx(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopSfx(lua_State *L) {
    StopSound(sfx);
    return 0;
}


extern (C) nothrow int luaL_playVideo(lua_State* L)
{
    try
    {
        videoFinished = false;
        playVideo(luaL_checkstring(L, 1).to!string);
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return 0;
}

/* ui animations */

extern (C) nothrow int luaL_loadUIAnimation(lua_State *L) {
    try {
        //loads from uifx folder HPFF files, in which png textures are stored
        framesUI = loadAnimationFramesUI(to!string(luaL_checkstring(L, 1)), to!string(luaL_checkstring(L, 2)));
        if (lua_gettop(L) == 3) {
            frameDuration = luaL_checknumber(L, 3);
            debug debugWriteln("frameDuration: ", frameDuration);
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_playUIAnimation(lua_State *L) {
    debug debugWriteln("Animation UI start");
    try {
        if (lua_gettop(L) == 0) playAnimation = true;
        else {
            debugWriteln("animationAlpha before reconfig: ", animationAlpha);
            animationAlpha = luaL_checkinteger(L, 1).to!ubyte;
            debugWriteln("animationAlpha after reconfig: ", animationAlpha);
            playAnimation = true;
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_stopUIAnimation(lua_State *L) {
    playAnimation = false;
    debug debugWriteln("Animation UI stop");
    frameDuration = 0.016f;
    currentFrame = 0;
    return 0;
}

extern (C) nothrow int luaL_unloadUIAnimation(lua_State *L) {
    try {
        for (int i = 0; i < framesUI.length; i++) {
            UnloadTexture(framesUI[i]);
        }
    } catch (Exception e) {
        debugWriteln(e.msg);
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

/* system */

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

float lastKeyPressTime = 0.0;
immutable float keyPressCooldown = 0.2;

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

extern (C) nothrow int luaL_getMouseX(lua_State *L) {
    lua_pushnumber(L, GetMousePosition.x);
    return 1;
}

extern (C) nothrow int luaL_getMouseY(lua_State *L) {
    lua_pushnumber(L, GetMousePosition.y);
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

ModelAnimation *modelAnimations;
int animationCurrentFrame = 0;
int animsCount = 0;

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

/* raylib direct bindings for graphics */

/* basic */

extern (C) nothrow int luaL_loadTexture(lua_State *L) {
    const char* fileName = luaL_checkstring(L, 1);
    Texture2D texture = LoadTexture(fileName);
    
    Texture2D* texturePtr = cast(Texture2D*)lua_newuserdata(L, Texture2D.sizeof);
    *texturePtr = texture;
    
    if (luaL_newmetatable(L, "Texture")) {
        lua_pushcfunction(L, &luaL_textureGC);
        lua_setfield(L, -2, "__gc");
    }
    SetTextureFilter(texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
    lua_setmetatable(L, -2);
    return 1;
}

extern (C) nothrow int luaL_textureGC(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
    UnloadTexture(*texture);
    return 0;
}

extern (C) nothrow int luaL_unloadTexture(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
    UnloadTexture(*texture);
    return 0;
}

extern (C) nothrow int luaL_drawTexture(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
    int x = cast(int)luaL_checkinteger(L, 2);
    int y = cast(int)luaL_checkinteger(L, 3);
    Color color = Colors.WHITE;
    
    if (lua_gettop(L) >= 4 && lua_istable(L, 4)) {
        lua_getfield(L, 4, "r");
        color.r = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 4, "g");
        color.g = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 4, "b");
        color.b = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, 4, "a");
        color.a = cast(ubyte)lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    
    DrawTextureEx(*texture, Vector2(x, y), 0.0f, scale, color);
    return 0;
}

extern (C) nothrow int luaL_getTextureWidth(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
    lua_pushnumber(L, texture.width*variables.scale);
    return 1;
}

extern (C) nothrow int luaL_getTextureHeight(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
    lua_pushnumber(L, texture.height*variables.scale);
    return 1;
}

extern (C) nothrow int luaL_drawText(lua_State *L) {
    const char* text = luaL_checkstring(L, 1);
    int x = cast(int)luaL_checkinteger(L, 2);
    int y = cast(int)luaL_checkinteger(L, 3);
    int fontSize = cast(int)luaL_optinteger(L, 4, 20);
    Color color = Colors.WHITE;
    if (lua_istable(L, 5)) {
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
    
    DrawTextEx(textFont, text, Vector2(x, y), fontSize, 1.0f, color);
    
    return 0;
}

extern (C) nothrow int luaL_measureTextX(lua_State *L) {
    lua_pushinteger(L, cast(int)MeasureTextEx(textFont, luaL_checkstring(L, 1), cast(int)luaL_checkinteger(L, 2), 1.0f).x);
    return 1;
}

extern (C) nothrow int luaL_measureTextY(lua_State *L) {
    lua_pushinteger(L, cast(int)MeasureTextEx(textFont, luaL_checkstring(L, 1), cast(int)luaL_checkinteger(L, 2), 1.0f).y);
    return 1;
}

/* extended */

extern (C) nothrow int luaL_drawTextureEx(lua_State *L) {
    Texture2D* texture = cast(Texture2D*)luaL_checkudata(L, 1, "Texture");
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

extern (C) nothrow int luaL_loadModel(lua_State *L) {
    const char* fileName = luaL_checkstring(L, 1);
    Model model = LoadModel(fileName);
    
    Model* modelPtr = cast(Model*)lua_newuserdata(L, Model.sizeof);
    *modelPtr = model;
    
    if (luaL_newmetatable(L, "Model")) {
        lua_pushcfunction(L, &luaL_textureGC);
        lua_setfield(L, -2, "__gc");
    }
    lua_setmetatable(L, -2);
    return 1;
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

/* Register functions */

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
    lua_register(L, "getMouseX", &luaL_getMouseX);
    lua_register(L, "getMouseY", &luaL_getMouseY);
    lua_register(L, "setGameState", &luaL_setGameState);
    lua_register(L, "setCamera", &luaL_setCamera);
    lua_register(L, "loadModelAnimations", &luaL_loadModelAnimations);
    lua_register(L, "updateModelAnimation", &luaL_updateModelAnimation);
    lua_register(L, "resetModelAnimation", &luaL_resetModelAnimation);
    
    //raylib direct bindings
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
    lua_register(L, "showCursor", &luaL_showCursor);
    lua_register(L, "hideCursor", &luaL_hideCursor);
    lua_register(L, "setMousePosition", &luaL_setMousePosition);

    //compat
    lua_register(L, "setFont", &luaL_loadFont);

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

void luaEventLoop()
{
    lua_getglobal(L, "EventLoop");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        debug debugWriteln("Error in EventLoop: ", to!string(lua_tostring(L, -1)));
    }
    lua_pop(L, 0);
}