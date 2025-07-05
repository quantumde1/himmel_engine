// quantumde1 developed software, licensed under MIT license.
import raylib;

import std.stdio;

//local imports
import graphics.engine;
import graphics.playback;
import variables;
import std.file;
import std.string;
import system.abstraction;
import system.config;
import std.conv;

void main(string[] args)
{
    validateRaylibBinding();
    debug {
        SetTraceLogLevel(0);
    } else {
        SetTraceLogLevel(7);
    }
    engine_loader();
}