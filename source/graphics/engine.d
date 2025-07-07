// quantumde1 developed software, licensed under MIT license.
module graphics.engine;

import raylib;

//dlang imports
import std.stdio;
import std.math;
import std.file;
import std.array;
import std.string;
import std.conv;
import std.typecons;
import std.random;
import std.datetime;

//graphics
import graphics.playback;
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

//C bindings
import core.stdc.stdlib;
import core.stdc.time;

void engine_loader()
{
    int screenWidth = 1344;
    int screenHeight = 1008;
    // Initialization
    debug debugWriteln("Engine version: ", ver);
    SetExitKey(0);
    Image icon = LoadImage("res/icon.png");
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, "Remember11 - Self Chapter");
    SetWindowIcon(icon);
    UnloadImage(icon);
    //ToggleFullscreen();
    SetTargetFPS(60);
    textFont = LoadFont("res/font_en.png");
    // Fade In and Out Effects
    InitAudioDevice();
    audioEnabled = systemSettings.sound_state.to!bool;
    helloScreen();
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
            luaExec = systemSettings.script_path;
            while (!WindowShouldClose())
            {
                SetExitKey(0);
                if (luaReload) {
                    resetAllScriptValues();
                    int luaExecutionCode = luaInit(luaExec);
                    if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
                        writeln("[ERROR] Engine stops execution according to error code: ", 
                        luaExecutionCode.to!EngineExitCodes);
                        currentGameState = GameState.Exit;
                        break;
                    }
                    luaReload = false;
                }
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
                luaEventLoop();
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