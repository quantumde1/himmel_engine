module ui.menu;

import aperture;
import variables;
import std.stdio;
import system.debugwriteln;
import graphics.gamelogic;
import std.conv : to;

int showMainMenu() {
    currentGameState = GameState.InGame; //TODO remove this.
    return EngineExitCodes.EXIT_OK;
}