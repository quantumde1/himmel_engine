module dialogs.dialogbox;

import raylib;
import std.string;
import std.uni;
import std.algorithm;
import variables;

// Dialog state variables
int currentPage = 0;
float textDisplayProgress = 0.0f;
bool textFullyDisplayed = false;

// Texture variables
float circleRotationAngle = 0.0f;

// Border sizes for 9-slice scaling
immutable int DIALOG_BORDER = 32; // Border that won't be stretched
immutable int CHOICE_BORDER = 32; // Choice window border

// Draws a texture with 9-slice scaling
void draw9SliceTexture(Texture2D tex, Rectangle dest, int borderSize, Color tint) {
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

// Main dialog display function
void displayDialog(string[] pages, string[] choices, ref int selectedChoice, 
                   int choicePage, Font dialogFont, bool* showDialog, 
                   ref float textSpeed, Texture2D circle, 
                   Texture2D dialogBackgroundTex, float scale) {
    
    immutable int screenWidth = systemSettings.screenWidth;
    immutable int screenHeight = systemSettings.screenHeight;
    immutable int screenPadding = 10;
    
    // Dialog background rectangle with padding
    Rectangle dialogRect = Rectangle(
        screenPadding,
        screenHeight - screenHeight/3 - screenPadding,
        screenWidth - 2*screenPadding,
        screenHeight/3
    );
    // Draw dialog background
    draw9SliceTexture(dialogBackgroundTex, dialogRect, DIALOG_BORDER, Colors.WHITE);
    
    // Text layout parameters
    immutable float textLeftMargin = 33.0f;
    immutable float textTopMargin = 20.0f;
    immutable float textRightMargin = 33.0f;
    immutable float textWidth = dialogRect.width - textLeftMargin - textRightMargin;
    immutable float fontSize = cast(int)(40.0f*scale);
    immutable float spacing = 1.0f;
    string name;
    
    // Text display logic
    string currentText = pages[currentPage];
    string displayText = currentText;

    if (currentText[0] == '[') {
        
        size_t start = currentText.indexOf('[') + 1;
        size_t end = currentText.lastIndexOf(']');
        name = currentText[start..end];
        
        size_t nameStart = currentText.indexOf('[');
        size_t nameEnd = currentText.lastIndexOf(']') + 1;
        displayText = currentText[0..nameStart] ~ currentText[nameEnd..$];
        Rectangle nameRect = Rectangle(
            screenPadding,
            dialogRect.y - screenHeight/12,
            screenWidth / 12 + MeasureTextEx(dialogFont, name.toStringz(), fontSize, spacing).x,
            screenHeight / 12
        );
        draw9SliceTexture(dialogBackgroundTex, nameRect, DIALOG_BORDER, Colors.WHITE);
        Vector2 nameSize = MeasureTextEx(dialogFont, name.toStringz(), fontSize, spacing);
        
        Vector2 namePos = Vector2(
            nameRect.x + (nameRect.width - nameSize.x) / 2,
            nameRect.y + (nameRect.height - nameSize.y) / 2
        );
        
        DrawTextEx(dialogFont, name.toStringz(), namePos + Vector2(3*scale, 3*scale), fontSize, spacing, Colors.BLACK);
        DrawTextEx(dialogFont, name.toStringz(), namePos, fontSize, spacing, Colors.WHITE);
    }

    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
        if (!textFullyDisplayed) {
            textDisplayProgress = displayText.length;
            textFullyDisplayed = true;
        } else {
            currentPage++;
            textDisplayProgress = 0.0f;
            textFullyDisplayed = false;
        }
    } else if (!textFullyDisplayed) {
        textDisplayProgress = min(textDisplayProgress + textSpeed, cast(float)displayText.length);
        textFullyDisplayed = textDisplayProgress >= displayText.length;
    }
    
    // Split text into lines that fit the dialog width
    string[] lines;
    string remaining = displayText[0..min(cast(int)textDisplayProgress, displayText.length)];
    
    while (!remaining.empty) {
        int fitChars = 0;
        float lineWidth = 0.0f;
        
        while (fitChars < remaining.length) {
            int wordEnd = fitChars;
            while (wordEnd < remaining.length && !remaining[wordEnd].isWhite) wordEnd++;
            
            string word = remaining[fitChars..wordEnd];
            float wordWidth = MeasureTextEx(dialogFont, word.toStringz(), fontSize, spacing).x;
            
            if (lineWidth > 0 && lineWidth + wordWidth > textWidth) break;
            
            lineWidth += wordWidth;
            fitChars = wordEnd;
            
            // Add whitespace
            while (fitChars < remaining.length && remaining[fitChars].isWhite) {
                lineWidth += MeasureTextEx(dialogFont, " ".toStringz(), fontSize, spacing).x;
                fitChars++;
            }
        }
        
        if (fitChars == 0) fitChars = 1;
        lines ~= remaining[0..fitChars];
        remaining = remaining[fitChars..$];
    }
    
    // Draw text lines with shadow effect
    immutable float lineHeight = MeasureTextEx(dialogFont, "A", fontSize, spacing).y * 1.4;
    foreach(i, line; lines) {
        Vector2 pos = Vector2(dialogRect.x + textLeftMargin, dialogRect.y + textTopMargin + i*lineHeight);
        DrawTextEx(dialogFont, line.toStringz(), pos + Vector2(3*scale, 3*scale), fontSize, spacing, Colors.BLACK);
        DrawTextEx(dialogFont, line.toStringz(), pos, fontSize, spacing, Colors.WHITE);
    }
    
    // Draw continue indicator when text is fully displayed
    if (textFullyDisplayed && !lines.empty) {
        circleRotationAngle = (circleRotationAngle + 45*GetFrameTime()) % 360;
        
        float lastLineWidth = MeasureTextEx(dialogFont, lines[$-1].toStringz(), fontSize, spacing).x;
        Vector2 circlePos = Vector2(
            (dialogRect.x + textLeftMargin + lastLineWidth + 20),
            (dialogRect.y + textTopMargin + ((lines.length)-1)*lineHeight)
        );
        
        float circleSize = 30.0f * scale;
        DrawTexturePro(
            circle,
            Rectangle(0, 0, circle.width, circle.height),
            Rectangle(circlePos.x, circlePos.y + (scale*20), circleSize, circleSize),
            Vector2(circleSize / 2, circleSize / 2),
            circleRotationAngle,
            Colors.WHITE
        );
    }
    
    // Choice selection logic
    if (textFullyDisplayed && (currentPage == choicePage)) {
        immutable choiceHeight = 50;
        immutable choiceSpacing = 10;
        immutable verticalPadding = 30;
        
        Rectangle choiceWindow = Rectangle(
            (screenWidth - screenWidth/2)/2,
            (screenHeight - (verticalPadding*2 + choices.length*(choiceHeight + choiceSpacing)))/2,
            screenWidth/2,
            verticalPadding*2 + choices.length*(choiceHeight + choiceSpacing)
        );
        
        draw9SliceTexture(dialogBackgroundTex, choiceWindow, CHOICE_BORDER, Colors.WHITE);
        
        Vector2 mousePos = GetMousePosition();
        bool mouseClicked = IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT);
        
        foreach(i, choice; choices) {
            Rectangle choiceRect = Rectangle(
                choiceWindow.x + 40,
                choiceWindow.y + verticalPadding + i*(choiceHeight + choiceSpacing),
                choiceWindow.width - 80,
                choiceHeight
            );
            
            bool hovered = CheckCollisionPointRec(mousePos, choiceRect);
            if (hovered) selectedChoice = cast(int)i;
            
            Vector2 textSize = MeasureTextEx(dialogFont, choice.toStringz(), fontSize, spacing);
            Vector2 textPos = Vector2(
                choiceRect.x + (choiceRect.width - textSize.x)/2,
                choiceRect.y + (choiceRect.height - textSize.y)/2
            );
            
            DrawTextEx(dialogFont, choice.toStringz(), textPos + Vector2(3*scale, 3*scale), fontSize, spacing, Colors.BLACK);
            DrawTextEx(dialogFont, choice.toStringz(), textPos, fontSize, spacing, 
                      (i == selectedChoice) ? Colors.YELLOW : (hovered ? Colors.LIGHTGRAY : Colors.WHITE));
            
            if (hovered && mouseClicked) {
                currentPage++;
                textDisplayProgress = 0.0f;
                textFullyDisplayed = false;
            }
        }
        // Keyboard navigation
        if (IsKeyPressed(KeyboardKey.KEY_DOWN)) selectedChoice = cast(int)((selectedChoice + 1) % choices.length);
        if (IsKeyPressed(KeyboardKey.KEY_UP)) selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length);
    }
    
    // Fast-forward with Ctrl
    if ((IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) || IsKeyDown(KeyboardKey.KEY_RIGHT_CONTROL)) 
        && currentPage != choicePage && currentPage < pages.length) {
        textFullyDisplayed = true;
        currentPage++;
    }
    
    // Close dialog when all pages are shown
    if (currentPage >= pages.length) {
        currentPage = 0;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
        *showDialog = false;
    }
}