// quantumde1 developed software, licensed under MIT license.
import raylib;

//local imports
import graphics.engine;

void main()
{
    validateRaylibBinding();
    debug {
        SetTraceLogLevel(0);
    } else {
        SetTraceLogLevel(7);
    }
    engineLoader();
}