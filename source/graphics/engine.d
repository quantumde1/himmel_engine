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
import ui.effects;

//dialogs
import dialogs.dialogbox;

//scripting imports
import scripts.lua;

//engine internal functions
import system.config;
import system.abstraction;
import variables;
import std.algorithm;
import graphics.collision;

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
    helloScreen();
    ClearBackground(Colors.BLACK);
    EndDrawing();
    camera = Camera3D(
        Vector3(0.0f, 10.0f, 8.0f),
        Vector3(0.0f, 5.0f, 0.0f),
        Vector3(0.0, 1.0, 0.0),
        90.0f,
        CameraProjection.CAMERA_PERSPECTIVE
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
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);

                    /* 3D part */
                    
                    luaEventLoopPre2D();

                    BeginMode3D(camera);
                    luaEventLoop3D();
                    EndMode3D();

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
                EndDrawing();
                resetAllScriptValues();
                debugWriteln("unloading font");
                UnloadFont(textFont);
                UnloadTexture(circle);
                UnloadTexture(dialogBackgroundTex);
                CloseAudioDevice();
                CloseWindow();
                return;

            default:
                break;
        }
    }
}