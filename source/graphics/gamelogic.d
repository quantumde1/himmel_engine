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

void unloadResourcesOnExit() {
    UnloadMusicStream(music);
    debugWriteln("unloading textures");
    for (int i = 0; i < textures.length; i++) {
        if (textures[i].id != 0) {
            debugWriteln("unloading texture index: ", i);
            UnloadTexture(textures[i]);
        }
    }
    debugWriteln("unloading shaders");
    for (int i = 0; i < shaders.length; i++) {
        if (shaders[i].id != 0) {
            debugWriteln("unloading shader index: ", i);
            UnloadShader(shaders[i]);
        }
    }
    debugWriteln("unloading models");
    for (int i = 0; i < models.length; i++) {
        if (models[i].meshCount != 0) {
            debugWriteln("unloading model index: ", i);
            UnloadModel(models[i]);
        }
    }
    UnloadRenderTexture(renderTexture);
    resetAllScriptValues();
    UnloadTexture(circle);
    UnloadTexture(dialogBackgroundTex);
    if (textFont.texture.id != 0) {
        UnloadFont(textFont);
    }
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
        dialogBox();
    }
}