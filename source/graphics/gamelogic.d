module graphics.gamelogic;

import raylib;
import bindbc.lua;
import variables;
import graphics.effects;
import std.string;
import std.math;
import dialogs.dialogbox;
import system.abstraction;
import std.conv;

/** 
 * this module contains game logic, which was removed from engine.d for better readability.
**/
 
void gameInit()
{
    circle = LoadTexture(systemSettings.dialogBoxEndIndicator.toStringz());
    dialogBackgroundTex = LoadTexture(systemSettings.dialogBoxBackground.toStringz());
    if (WindowShouldClose()) {
        currentGameState = GameState.Exit;
    } else {
        debugWriteln("Game initializing.");
        luaExec = systemSettings.scriptPath;
    }
}

nothrow void unloadResourcesOnExit() {
    resetAllScriptValues();
    debugWriteln("unloading font");
    UnloadFont(textFont);
    UnloadTexture(circle);
    UnloadTexture(dialogBackgroundTex);
    lua_getglobal(L, "OnGameExit");
    if (lua_isfunction(L, -1)) {
        if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
            debug debugWriteln("Error in OnGameExit: ", to!string(lua_tostring(L, -1)));
        }
    }
    lua_pop(L, 1);
}

void texturesLogic(TextureEngine[] textures) {
    for (int i = 0; i < textures.length; i++) {
        if (textures[i].drawTexture) {
            if (textures[i].alpha < 1.0f) {
                textures[i].alpha += GetFrameTime() * textures[i].fadeSpeed;
                if (textures[i].alpha > 1.0f) textures[i].alpha = 1.0f;
            }
        } else {
            if (textures[i].alpha > 0.0f) {
                textures[i].alpha -= GetFrameTime() * textures[i].fadeSpeed;
                if (textures[i].alpha < 0.0f) textures[i].alpha = 0.0f;
            }
        }

        if (textures[i].alpha > 0.0f) {
            float centeredX = textures[i].x - (textures[i].width * textures[i].scale / 2);
            float centeredY = textures[i].y - (textures[i].height * textures[i].scale / 2);
            
            Color tint = textures[i].color;
            tint.a = cast(ubyte)(255 * textures[i].alpha);
            
            DrawTextureEx(textures[i].texture,
                Vector2(centeredX, centeredY),
                0.0,
                textures[i].scale,
                tint
            );
        }
    }
}

void effectsLogic() {
    UpdateMusicStream(music);
    playUIAnimation(framesUI, animationAlpha);
}

void backgroundLogic() {
    texturesLogic(backgroundTextures);
}

void characterLogic() {
    texturesLogic(characterTextures);
}

void dialogLogic() {
    if (showDialog) {
        displayDialog(messageGlobal, choices, selectedChoice, choicePage, textFont, &showDialog, typingSpeed, 
        circle, dialogBackgroundTex, scale);
    }
}