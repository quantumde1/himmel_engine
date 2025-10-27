module ui.menu;

import raylib;
import variables;
import std.stdio;
import system.abstraction;
import graphics.playback;
import scripts.lua.core;
import graphics.gamelogic;
import std.conv : to;

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
        luaEventLoopPost2D();
        EndDrawing();
    }
    debugWriteln("menu assets unloading");
    StopMusicStream(music);
    UnloadMusicStream(music);
    music = Music();
    luaReload = true;
    return EngineExitCodes.EXIT_OK;
}