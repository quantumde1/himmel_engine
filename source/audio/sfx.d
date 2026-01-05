module graphics.effects;

import raylib;
import std.stdio;
import variables;
import std.string;
import system.debugwriteln;
import std.file;

Sound sfx;

void playSfx(string filename) {
    debug debugWriteln("Loading & playing SFX");
    sfx = LoadSound(filename.toStringz());
    PlaySound(sfx);
}