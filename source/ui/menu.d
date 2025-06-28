module ui.menu;

import raylib;
import variables;
import std.stdio;
import system.abstraction;
import system.config;
import core.time;
import core.thread;
import std.string;
import graphics.engine;
import graphics.playback;
import std.file;
import scripts.lua;
import std.conv;
import graphics.gamelogic;

enum
{
    MENU_ITEM_START = 0,
    MENU_ITEM_SOUND = 1,
    MENU_ITEM_SFX = 2,
    MENU_ITEM_FULLSCREEN = 3,
    MENU_ITEM_EXIT = 4,

    FADE_SPEED_IN = 0.02f,
    FADE_SPEED_OUT = 0.04f,
    INACTIVITY_TIMEOUT = 20.0f
}

void fadeEffect(float alpha, bool fadeIn, void delegate(float alpha) renderer)
{
    const float FadeIncrement = 0.02f;

    while (fadeIn ? alpha < 2.0f : alpha > 0.0f)
    {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        renderer(alpha);
        EndDrawing();
    }
}

void renderText(float alpha, immutable(char)* text)
{
    DrawTextEx(textFont, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );
}

void renderLogo(float alpha, immutable(char)* name, bool fullscreen)
{
    Texture2D companyLogo = LoadTexture(name);
    if (fullscreen) {
        DrawTexturePro(companyLogo,
            Rectangle(0, 0, cast(float) companyLogo.width, cast(float) companyLogo.height),
            Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight()),
            Vector2(0, 0), 0.0, Fade(Colors.WHITE, alpha));
    }
    else {
        DrawTexture(companyLogo, GetScreenWidth() / 2, GetScreenHeight() / 2, Colors.WHITE);
    }
}

void helloScreen()
{
    debug
    {
        bool play = false;
        debugWriteln("hello screen showing");
        if (play == false) {
            videoFinished = true;
            goto debug_lab;
        }
    }
    else {
        fadeEffect(0.0f, true, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });

        fadeEffect(2.0f, false, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });
        /*
        fadeEffect(0.0f, true, (float alpha) {
            renderLogo(alpha, "atlus_logo.png".toStringz, true);
        });
        
        fadeEffect(fadeAlpha, false, (float alpha) {
            renderLogo(alpha, "atlus_logo.png".toStringz, true);
        });
        */
        // Play Opening Video
        BeginDrawing();
        debug debugWriteln("searching for video");
        if (std.file.exists(getcwd() ~ "/res/videos/soul_OP.moflex.mp4"))
        {
            debug debugWriteln("video found, playing");
            playVideo("/res/videos/soul_OP.moflex.mp4");
        }
        else {
            debug debugWriteln("video not found, skipping");
            videoFinished = true;
        }
    }
    debug_lab:
}

int showMainMenu() {
    int luaExecutionCode = luaInit("scripts/menu.lua");
    if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
        debugWriteln("Engine stops execution according to error code: ", 
        luaExecutionCode.to!EngineExitCodes);
        currentGameState = GameState.Exit;
        return luaExecutionCode;
    }
    luaReload = false;
    while (currentGameState == GameState.MainMenu)
    {
        UpdateMusicStream(music);
        luaEventLoop();
        BeginDrawing();
        BeginMode2D(camera);
        backgroundLogic();
        EndMode2D();
        EndDrawing();
    }
    StopMusicStream(music);
    UnloadMusicStream(music);
    luaReload = true;
    return 0;
}