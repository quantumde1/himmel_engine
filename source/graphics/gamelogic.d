module graphics.gamelogic;

import raylib;
import bindbc.lua;
import variables;
import core.stdc.stdlib;
import core.stdc.time;
import graphics.engine;
import scripts.lua;
import std.stdio;
import std.conv;
import graphics.effects;
import std.string;
import std.math;
import dialogs.dialogbox;
import system.abstraction;
import system.config;
import std.file;

/** 
 * this module contains game logic, which was removed from engine.d for better readability.
 */
 
void gameInit()
{
    circle = LoadTexture("res/misc/circle.png");
    dialogBackgroundTex = LoadTexture("res/misc/TEX#win_01d.PNG");
    choiceWindowTex = LoadTexture("res/misc/TEX#win_00d.PNG");
    if (WindowShouldClose()) {
        currentGameState = GameState.Exit;
    } else {
        debugWriteln("Game initializing.");
        systemSettings = loadSettingsFromConfigFile();
    }
}

void effectsLogic()
{
    UpdateMusicStream(music);
    if (isCameraMoving) {
        float delta = GetFrameTime() * cameraMoveSpeed;
        camera.target.x += (cameraTargetX - camera.target.x) * delta;
        camera.target.y += (cameraTargetY - camera.target.y) * delta;
        camera.zoom += (cameraTargetZoom - camera.zoom) * delta;

        if (fabs(camera.target.x - cameraTargetX) < 5.0f &&
            fabs(camera.target.y - cameraTargetY) < 5.0f &&
            fabs(camera.zoom - cameraTargetZoom) < 0.5f) {
            isCameraMoving = false;
        }
    }
    playUIAnimation(framesUI);
}

void backgroundLogic() {
    if (backgroundFades.length < backgroundTextures.length) {
        backgroundFades.length = backgroundTextures.length;
    }

    for (int i = 0; i < backgroundTextures.length; i++) {
        if (backgroundTextures[i].drawTexture) {
            if (backgroundFades[i].alpha < 1.0f) {
                backgroundFades[i].alpha += GetFrameTime() * backgroundFades[i].fadeSpeed;
                if (backgroundFades[i].alpha > 1.0f) backgroundFades[i].alpha = 1.0f;
            }
        } else {
            if (backgroundFades[i].alpha > 0.0f) {
                backgroundFades[i].alpha -= GetFrameTime() * backgroundFades[i].fadeSpeed;
                if (backgroundFades[i].alpha < 0.0f) backgroundFades[i].alpha = 0.0f;
            }
        }

        if (backgroundFades[i].alpha > 0.0f) {
            float centeredX = backgroundTextures[i].x - (backgroundTextures[i].width * backgroundTextures[i].scale / 2);
            float centeredY = backgroundTextures[i].y - (backgroundTextures[i].height * backgroundTextures[i].scale / 2);
            
            Color tint = Colors.WHITE;
            tint.a = cast(ubyte)(255 * backgroundFades[i].alpha);
            
            DrawTextureEx(backgroundTextures[i].texture,
                Vector2(centeredX, centeredY),
                0.0,
                backgroundTextures[i].scale,
                tint
            );
        }
    }
}

void characterLogic() {
    if (characterFades.length < characterTextures.length) {
        characterFades.length = characterTextures.length;
    }

    for (int i = 0; i < characterTextures.length; i++) {
        if (characterTextures[i].drawTexture) {
            if (characterTextures[i].justDrawn) {
                characterFades[i].alpha = 0.0f;
                characterTextures[i].justDrawn = false;
            }
            
            if (characterFades[i].alpha < 1.0f) {
                characterFades[i].alpha += GetFrameTime() * characterFades[i].fadeSpeed;
                if (characterFades[i].alpha > 1.0f) characterFades[i].alpha = 1.0f;
            }
        } else {
            if (characterFades[i].alpha > 0.0f) {
                characterFades[i].alpha -= GetFrameTime() * characterFades[i].fadeSpeed;
                if (characterFades[i].alpha < 0.0f) {
                    characterFades[i].alpha = 0.0f;
                }
            }
        }

        if (characterFades[i].alpha > 0.0f) {
            float centeredX = characterTextures[i].x - (characterTextures[i].width * characterTextures[i].scale / 2);
            float centeredY = characterTextures[i].y - (characterTextures[i].height * characterTextures[i].scale / 2);
            
            
            characterColor.a = cast(ubyte)(255 * characterFades[i].alpha);
            
            DrawTextureEx(characterTextures[i].texture,
                        Vector2(centeredX, centeredY), 
                        0.0, 
                        characterTextures[i].scale, 
                        characterColor);
        }
    }
}

void dialogLogic() {
    if (showDialog) {
        displayDialog(messageGlobal, choices, selectedChoice, choicePage, textFont, &showDialog, typingSpeed, 
        circle, dialogBackgroundTex, choiceWindowTex);
    }
}