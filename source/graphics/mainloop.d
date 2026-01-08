module graphics.mainloop;

import aperture;

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
                    SetTargetFPS(60);
                    PollWindowEvents();
                    UpdateInput();
                    executer();
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);
                    // main logic
                    backgroundLogic();
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
                unloadResourcesLogic();
                CloseWindow();
                return;
            default:
                break;
        }
    }
}