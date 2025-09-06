module ui.menu;

import raylib;
import variables;
import std.stdio;
import system.abstraction;
import graphics.playback;
import scripts.lua;
import graphics.gamelogic;
import std.conv : to;

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

void helloScreen()
{
    debug
    {
        bool play = false;
        debugWriteln("hello screen showing");
        if (play == false) {
            videoFinished = true;
        }
    } else {
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
    }
}

int showMainMenu() {
    int luaExecutionCode = luaInit(systemSettings.menuScriptPath);
    if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
        writeln("[ERROR] Engine stops Lua execution according to error code: ", 
        luaExecutionCode.to!EngineExitCodes);
        currentGameState = GameState.Exit;
        return luaExecutionCode;
    }
    luaReload = false;
    while (currentGameState == GameState.MainMenu)
    {
        ClearBackground(Colors.WHITE);
        if (IsKeyPressed(KeyboardKey.KEY_F11)) {
            ToggleFullscreen();
        }
        UpdateMusicStream(music);
        BeginDrawing();
        backgroundLogic();
        effectsLogic();
        luaEventLoop();
        EndDrawing();
    }
    debugWriteln("menu assets unloading");
    StopMusicStream(music);
    UnloadMusicStream(music);
    music = Music();
    luaReload = true;
    return EngineExitCodes.EXIT_OK;
}