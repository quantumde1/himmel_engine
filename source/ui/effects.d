module ui.effects;

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
    screenWidth = systemSettings.screenWidth;
    screenHeight = systemSettings.screenHeight;
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

void playUIAnimation(Texture2D[] frames)
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
            Color(255, 255, 255, 127)
        );
    } else {
        frameTime = 0.0f;
        currentFrame = 0;
    }
}


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
    DrawTextEx(textFont, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );
}

void helloScreen()
{
    debug
    {
        bool play = false;
        debugWriteln("hello screen showing");
        if (play == false) {
            videoFinished = true;
        }
    } else {
        fadeEffect(0.0f, true, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });

        fadeEffect(2.0f, false, (float alpha) {
            renderText(alpha, "powered by\n\nHimmel Engine");
        });
        /*
        fadeEffect(0.0f, true, (float alpha) {
            renderLogo(alpha, "atlus_logo.png".toStringz, true);
        });
        
        fadeEffect(fadeAlpha, false, (float alpha) {
            renderLogo(alpha, "atlus_logo.png".toStringz, true);
        });
        */
        // Play Opening Video
    }
}