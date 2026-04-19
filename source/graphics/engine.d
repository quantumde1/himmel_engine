// quantumde1 developed software, licensed under MIT license.
module graphics.engine;

import raylib;

//dlang imports
import std.stdio;
import std.string;
import std.conv;

//graphics
import graphics.gamelogic;
import ui.menu;

//dialogs
import dialogs.dialogbox;

//scripting imports
import scripts.lua;

//engine internal functions
import system.config;
import system.abstraction;
import variables;
import system.cleanup;
import std.algorithm;

void engineLoader()
{
    systemSettings = loadSettingsFromConfigFile("conf/settings.conf");
    baseWidth = systemSettings.defaultScreenWidth;
    baseHeight = systemSettings.defaultScreenHeight;
    int screenWidth = systemSettings.screenWidth;
    int screenHeight = systemSettings.screenHeight;
    scale = min(cast(float)(screenWidth/baseWidth), cast(float)(screenHeight/baseHeight));
    debugWriteln("scale: ", scale);
    // Initialization
    SetExitKey(0);
    Image icon = LoadImage(systemSettings.iconPath.toStringz());
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, systemSettings.windowTitle.toStringz());
    if (systemSettings.defaultFullscreen == true) {
        ToggleFullscreen();
    }
    SetWindowIcon(icon);
    UnloadImage(icon);
    //ToggleFullscreen();
    SetTargetFPS(60);
    //fallback font?
    textFont = LoadFont(systemSettings.fallbackFont.toStringz());
    // Fade In and Out Effects
    InitAudioDevice();
    //helloScreen();
    ClearBackground(Colors.BLACK);
    EndDrawing();
    camera.target = Vector2(screenWidth/2.0f, screenHeight/2.0f);
    camera.offset = Vector2(screenWidth/2.0f, screenHeight/2.0f);
    camera.rotation = 0.0f;
    camera.zoom = 1.0f;
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
                    if (IsKeyPressed(KeyboardKey.KEY_F11)) {
                        ToggleFullscreen();
                    }
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);
                    // main logic
                    BeginMode2D(camera);
                    backgroundLogic();
                    characterLogic();
                    // effects logic
                    effectsLogic();
                    EndMode2D();
                    //drawing dialogs
                    dialogLogic();
                    if (pauseParser == false) {
                        //lua is up and running
                        luaEventLoop();
                    }
                    EndDrawing();
                }
                break;
            case GameState.Exit:
                EndDrawing();
                unloadResourcesLogic();
                CloseAudioDevice();
                CloseWindow();
                return;

            default:
                break;
        }
    }
}