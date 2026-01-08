module message.messagebox;

import aperture;
import std.string;
import std.uni;
import std.algorithm;
import variables;

// Draws a texture with 9-slice scaling
void draw9SliceTexture(Texture tex, Rectangle dest, int borderSize, Color tint) {
    Rectangle src = Rectangle(0, 0, tex.width, tex.height);
    
    // Prevent invalid border sizes
    borderSize = max(1, min(borderSize, tex.width/3, tex.height/3));
    
    Rectangle innerSrc = Rectangle(
        borderSize, borderSize, 
        src.width - borderSize*2, src.height - borderSize*2
    );
    
    Rectangle innerDest = Rectangle(
        dest.x + borderSize, dest.y + borderSize,
        dest.width - borderSize*2, dest.height - borderSize*2
    );
    
    // Draw all 9 parts
    void drawPart(Rectangle s, Rectangle d) {
        DrawTexturePro(tex, s, d, Vector2(0, 0), 0, tint);
    }
    
    // Corners
    drawPart(Rectangle(src.x, src.y, borderSize, borderSize),
             Rectangle(dest.x, dest.y, borderSize, borderSize));
    drawPart(Rectangle(src.x + src.width - borderSize, src.y, borderSize, borderSize),
             Rectangle(dest.x + dest.width - borderSize, dest.y, borderSize, borderSize));
    drawPart(Rectangle(src.x, src.y + src.height - borderSize, borderSize, borderSize),
             Rectangle(dest.x, dest.y + dest.height - borderSize, borderSize, borderSize));
    drawPart(Rectangle(src.x + src.width - borderSize, src.y + src.height - borderSize, borderSize, borderSize),
             Rectangle(dest.x + dest.width - borderSize, dest.y + dest.height - borderSize, borderSize, borderSize));
    
    // Edges
    drawPart(Rectangle(src.x + borderSize, src.y, innerSrc.width, borderSize),
             Rectangle(dest.x + borderSize, dest.y, innerDest.width, borderSize));
    drawPart(Rectangle(src.x, src.y + borderSize, borderSize, innerSrc.height),
             Rectangle(dest.x, dest.y + borderSize, borderSize, innerDest.height));
    drawPart(Rectangle(src.x + src.width - borderSize, src.y + borderSize, borderSize, innerSrc.height),
             Rectangle(dest.x + dest.width - borderSize, dest.y + borderSize, borderSize, innerDest.height));
    drawPart(Rectangle(src.x + borderSize, src.y + src.height - borderSize, innerSrc.width, borderSize),
             Rectangle(dest.x + borderSize, dest.y + dest.height - borderSize, innerDest.width, borderSize));
    
    // Center
    drawPart(innerSrc, innerDest);
}

int countSymbols;

void displayMessage() {
    pauseParser = true;
    immutable int screenWidth = systemSettings.screenWidth;
    immutable int screenHeight = systemSettings.screenHeight;
    immutable int screenPadding = 10;
    Rectangle dialogRect = Rectangle(
        screenPadding,
        screenHeight - screenHeight + screenPadding,
        screenWidth - 2*screenPadding,
        screenHeight/3
    );
    draw9SliceTexture(dialogBackgroundTex, dialogRect, 32, Colors.WHITE);
    if (countSymbols < cast(int)messageGlobal.length) {
        countSymbols++;
    }
    if (countSymbols == cast(int)messageGlobal.length) {
        isTextFullyDisplayed = true;
    }
    if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
        if (isTextFullyDisplayed == true) {
            isTextFullyDisplayed = false;
            countSymbols = 0;
            pauseParser = false;
            showDialog = false;
        } else {
            countSymbols =  cast(int)messageGlobal.length;
        }
    }
    DrawTextWithFont(cast(char*)messageGlobal[0..countSymbols].toStringz(), 52, screenHeight/3-26, 0.9*scale, Colors.BLACK);
    DrawTextWithFont(cast(char*)messageGlobal[0..countSymbols].toStringz(), 50, screenHeight/3-23, 0.9*scale, Colors.WHITE);
}
