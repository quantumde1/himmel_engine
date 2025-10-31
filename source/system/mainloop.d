module system.mainloop;

import variables;
import ui.menu;
import system.abstraction;
import graphics.gamelogic;
import raylib;
import std.stdio;
import std.conv;
import scripts.lua.core;
import std.algorithm;

void mainLoop() {
    renderTexture = LoadRenderTexture(renderTextureWidth, renderTextureHeight);
    float renderScale = min(
        cast(float)GetScreenWidth() / renderTextureWidth,
        cast(float)GetScreenHeight() / renderTextureHeight
    );
    while (true)
    {
        switch (currentGameState)
        {
            case GameState.MainMenu:
                debugWriteln("Showing menu.");
                showMainMenu();
                break;
            case GameState.InGame:
                gameInit();
                while (!WindowShouldClose())
                {
                    if (luaReload) {
                        resetAllScriptValues();
                        int luaExecutionCode = luaInit(luaExec);
                        if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
                            writeln("[ERROR] Engine stops Lua execution according to error code: ", 
                            luaExecutionCode.to!EngineExitCodes);
                            currentGameState = GameState.Exit;
                            break;
                        }
                        luaReload = false;
                    }
                    SetExitKey(0);
                    if (IsKeyPressed(KeyboardKey.KEY_F)) {
                        ToggleFullscreen();
                    }
                    BeginTextureMode(renderTexture);
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);

                    /* 3D part */
                    
                    luaEventLoopPre2D();

                    BeginMode3D(camera);
                    luaEventLoop3D();
                    EndMode3D();

                    EndTextureMode();
                    
                    DrawTexturePro(
                        renderTexture.texture,
                        Rectangle(0, 0, renderTextureWidth, -renderTextureHeight),
                        Rectangle(
                            (GetScreenWidth() - (renderTextureWidth * renderScale)) * 0.5f,
                            (GetScreenHeight() - (renderTextureHeight * renderScale)) * 0.5f,
                            renderTextureWidth * renderScale,
                            renderTextureHeight * renderScale
                        ),
                        Vector2(0, 0),
                        0.0f,
                        Colors.WHITE
                    );

                    luaEventLoopPost2D();
                    /* 2D part */
                    
                    // background display logic
                    backgroundLogic();
                    // character display logic
                    characterLogic();
                    // effects logic
                    effectsLogic();
                    //drawing dialogs
                    dialogLogic();

                    EndDrawing();
                }
                break;
            case GameState.Exit:
                unloadResourcesOnExit();
                CloseAudioDevice();
                debugWriteln("closing window!");
                CloseWindow();
                return;
            default:
                break;
        }
    }
}