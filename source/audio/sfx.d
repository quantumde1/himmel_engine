module audio.sfx;

import raylib;
import std.string;
import system.abstraction;

Sound sfx;

void playSfx(string filename) {
    debug debugWriteln("Loading & playing SFX");
    sfx = LoadSound(filename.toStringz());
    PlaySound(sfx);
}