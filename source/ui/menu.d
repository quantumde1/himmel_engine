module ui.menu;

import aperture;
import variables;
import std.stdio;
import system.debugwriteln;
import graphics.gamelogic;
import std.conv : to;

void helloScreen()
{
    debug
    {
        debugWriteln("hello screen showing");
    } else {
        fadeEffect(0.0f, true, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });

        fadeEffect(2.0f, false, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });
    }
}

int showMainMenu() {
    currentGameState = GameState.InGame; //TODO remove this.
    return EngineExitCodes.EXIT_OK;
}