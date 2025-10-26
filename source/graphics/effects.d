module graphics.effects;

import raylib;
import std.stdio;
import variables;
import std.string;
import system.abstraction;
import std.file;

int screenWidth;
int screenHeight;

Texture2D[] loadAnimationFramesUI(const string fileDir, const string animationFileName)
{
    screenWidth = systemSettings.defaultScreenWidth;
    screenHeight = systemSettings.defaultScreenHeight;
    Texture2D[] frames;
    uint frameIndex = 1;
    while (true)
    {
        string frameFileName = format("%s-%03d.png", animationFileName, frameIndex);
        if (std.file.exists(fileDir~"/"~frameFileName) == false) break;
        debug debugWriteln(frameFileName);
        Texture2D texture = LoadTexture((fileDir~"/"~frameFileName).toStringz());
        frames ~= texture;
        debug debugWriteln("Loaded frame for UI ", frameIndex, " - ", frameFileName);
        frameIndex++;
    }
    debug debugWriteln("Frames for ui animations length: ", frames.length);
    return frames;
}

void playUIAnimation(Texture2D[] frames, ubyte alpha)
{
    static float frameTime = 0.0f;
    
    if (playAnimation) {
        frameTime += GetFrameTime();
        
        while (frameTime >= frameDuration && frameDuration > 0) {
            frameTime -= frameDuration;
            currentFrame = cast(int)((currentFrame + 1) % frames.length);
        }

        int frameWidth = frames[currentFrame].width;
        int frameHeight = frames[currentFrame].height;
        
        DrawTexturePro(
            frames[currentFrame],
            Rectangle(0, 0, frameWidth, frameHeight),
            Rectangle(0, 0, screenWidth, screenHeight),
            Vector2(0, 0),
            0,
            Color(255, 255, 255, alpha)
        );
    } else {
        frameTime = 0.0f;
        currentFrame = 0;
    }
}