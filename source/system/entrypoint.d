// quantumde1 developed software, licensed under MIT license.
module system.entrypoint;

import aperture;

//dlang imports
import std.string;
import std.algorithm;

//graphics
import graphics.gamelogic;
import ui.menu;

//scripting imports
import scripts.hbs;

//engine internal functions
import system.configreader;
import system.debugwriteln;
import variables;
import graphics.mainloop;

int index = 0;
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
    int argc;
    char** argv;
    // Window and Audio Initialization
    InitWindow(argc, argv, screenWidth, screenHeight, systemSettings.windowTitle.toStringz());
    if (systemSettings.defaultFullscreen == true) {
        //ToggleFullscreen();
    }
    //fallback font?
    // Fade In and Out Effects
    helloScreen();
    ClearBackground(Colors.BLACK);
    EndDrawing();
    mainLoop();
}