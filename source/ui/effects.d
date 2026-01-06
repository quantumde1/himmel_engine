module ui.effects;

import aperture;
import std.stdio;
import variables;
import std.string;
import system.debugwriteln;
import std.file;

void fadeEffect(float alpha, bool fadeIn, void delegate(float alpha) renderer)
{
    const float FadeIncrement = 0.02f;

    while (fadeIn ? alpha < 2.0f : alpha > 0.0f)
    {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        renderer(alpha);
        EndDrawing();
    }
}

void renderText(float alpha, immutable(char)* text)
{
    /*DrawTextEx(textFont, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );*/
}

// these variables needed between loadAnimationFramesUI and playUIAnimation
private int screenWidth;
private int screenHeight;

Texture[] loadInterfaceAnimation(const string fileDir, const string animationFileName)
{
    screenWidth = systemSettings.defaultScreenWidth;
    screenHeight = systemSettings.defaultScreenHeight;
    Texture[] frames;
    uint frameIndex = 1;
    while (true)
    {
        string frameFileName = format("%s-%03d.png", animationFileName, frameIndex);
        if (std.file.exists(fileDir~"/"~frameFileName) == false) break;
        debug debugWriteln(frameFileName);
        Texture texture = LoadTexture((fileDir~"/"~frameFileName).toStringz());
        frames ~= texture;
        debug debugWriteln("Loaded frame for UI ", frameIndex, " - ", frameFileName);
        frameIndex++;
    }
    debug debugWriteln("Frames for ui animations length: ", frames.length);
    return frames;
}

void playInterfaceAnimation(Texture[] frames, ubyte alpha)
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
        
        /*DrawTexturePro(
            frames[currentFrame],
            Rectangle(0, 0, frameWidth, frameHeight),
            Rectangle(0, 0, screenWidth, screenHeight),
            Vector2(0, 0),
            0,
            Color(255, 255, 255, alpha)
        );*/
    } else {
        frameTime = 0.0f;
        currentFrame = 0;
    }
}