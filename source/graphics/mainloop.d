module graphics.mainloop;

import raylib;

//dlang imports
import std.conv;

//graphics
import graphics.gamelogic;
import ui.menu;

//scripting imports
import scripts.hbs;

//engine internal functions
import system.configreader;
import system.debugwriteln;
import variables;
import system.cleanup;
import std.file;

void mainLoop() {
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
                if (currentGameState == GameState.InGame) {
                    ubyte[] file = cast(ubyte[])read(hbsFirstExec);
                    loader(file);
                    parser(file);
                }
                if (std.file.exists("save.txt")) {
                    int savedCommandIndex = std.file.readText("save.txt").to!int;
                    saveLoader(savedCommandIndex);
                }
                while (!WindowShouldClose())
                {
                    SetExitKey(0);
                    if (IsKeyPressed(KeyboardKey.KEY_F11)) {
                        ToggleFullscreen();
                    }
                    executer();
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
                    DrawFPS(10, 10);
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