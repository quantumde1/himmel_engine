module system.cleanup;

import std.stdio;
import variables;
import raylib;
import system.abstraction;

void unloadResourcesLogic()
{
    debugWriteln("Exiting. See ya'!");
    EndDrawing();
    debugWriteln("unloading animations");
    for (int i = 0; i < framesUI.length; i++) {
        UnloadTexture(framesUI[i]);
    }
    debugWriteln("unloading font");
    UnloadFont(textFont);
    debugWriteln("unloading characters");
    for (int i = 0; i < characterTextures.length; i++) {
        UnloadTexture(characterTextures[i].texture);
    }
    debugWriteln("unloading backgrounds");
    for (int i = 0; i < backgroundTextures.length; i++) {
        UnloadTexture(backgroundTextures[i].texture);
    }
}