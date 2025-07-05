module system.cleanup;

import std.stdio;
import variables;
import raylib;
import system.abstraction;

void unloadResourcesLogic()
{
    debugWriteln("Exiting. See ya'!");
    EndDrawing();
    for (int i = cast(int)framesUI.length; i < framesUI.length; i++) {
        debugWriteln("unloading animations");
        UnloadTexture(framesUI[i]);
    }
    UnloadFont(textFont);
    for (int i = cast(int)characterTextures.length; i < characterTextures.length; i++) {
        UnloadTexture(characterTextures[i].texture);
    }
    for (int i = cast(int)backgroundTextures.length; i < backgroundTextures.length; i++) {
        UnloadTexture(backgroundTextures[i].texture);
    }
}