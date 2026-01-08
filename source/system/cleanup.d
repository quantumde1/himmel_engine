module system.cleanup;

import std.stdio;
//import std.conv;
//import std.file;
import variables;
import aperture;
import system.debugwriteln;
import vibration;

void unloadResourcesLogic()
{
    debugWriteln("Exiting. See ya'!");
    EndDrawing();
    debugWriteln("unloading music");
    StopMusic();
    UnloadMusic();
    debugWriteln("unloading animations");
    for (int i = 0; i < framesUI.length; i++) {
        UnloadTexture(framesUI[i]);
    }
    debugWriteln("unloading font");
    UnloadFont();
    debugWriteln("unloading characters");
    for (int i = 0; i < characterTextures.length; i++) {
        UnloadTexture(characterTextures[i].texture);
    }
    debugWriteln("unloading backgrounds");
    for (int i = 0; i < backgroundTextures.length; i++) {
        UnloadTexture(backgroundTextures[i].texture);
    }
    //std.file.write("save.txt", currentCommandIndex.to!string);
}