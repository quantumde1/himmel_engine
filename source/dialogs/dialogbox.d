module dialogs.dialogbox;

import raylib;
import std.string;
import std.stdio;
import std.conv;
import std.uni;
import std.typecons;
import std.algorithm;
import variables;

int currentPage = 0;
float textDisplayProgress = 0.0f;
bool textFullyDisplayed = false;

// Texture variables
bool texturesLoaded = false;
float circleRotationAngle = 0.0f;

// Border sizes for 9-slice scaling
const int DIALOG_BORDER = 32; // Border size that won't be stretched
const int CHOICE_BORDER = 32;  // Border size for choice window

void draw9SliceTexture(Texture2D tex, Rectangle dest, int borderSize, Color tint) {
    // Source rectangle is the whole texture
    Rectangle src = Rectangle(0, 0, tex.width, tex.height);
    
    // Prevent division by zero
    if (borderSize <= 0) borderSize = 1;
    if (borderSize * 2 >= src.width) borderSize = cast(int)src.width / 3;
    if (borderSize * 2 >= src.height) borderSize = cast(int)src.height / 3;
    
    // Calculate inner source rectangle (without borders)
    Rectangle innerSrc = Rectangle(
        borderSize, 
        borderSize, 
        src.width - borderSize * 2, 
        src.height - borderSize * 2
    );
    
    // Calculate inner destination rectangle
    Rectangle innerDest = Rectangle(
        dest.x + borderSize, 
        dest.y + borderSize, 
        dest.width - borderSize * 2, 
        dest.height - borderSize * 2
    );
    
    // Draw 9 parts:
    // 1. Top-left corner
    DrawTexturePro(tex, 
        Rectangle(src.x, src.y, borderSize, borderSize),
        Rectangle(dest.x, dest.y, borderSize, borderSize),
        Vector2(0, 0), 0, tint);
    
    // 2. Top edge
    DrawTexturePro(tex, 
        Rectangle(src.x + borderSize, src.y, innerSrc.width, borderSize),
        Rectangle(dest.x + borderSize, dest.y, innerDest.width, borderSize),
        Vector2(0, 0), 0, tint);
    
    // 3. Top-right corner
    DrawTexturePro(tex, 
        Rectangle(src.x + src.width - borderSize, src.y, borderSize, borderSize),
        Rectangle(dest.x + dest.width - borderSize, dest.y, borderSize, borderSize),
        Vector2(0, 0), 0, tint);
    
    // 4. Left edge
    DrawTexturePro(tex, 
        Rectangle(src.x, src.y + borderSize, borderSize, innerSrc.height),
        Rectangle(dest.x, dest.y + borderSize, borderSize, innerDest.height),
        Vector2(0, 0), 0, tint);
    
    // 5. Center (stretched)
    DrawTexturePro(tex, 
        innerSrc,
        innerDest,
        Vector2(0, 0), 0, tint);
    
    // 6. Right edge
    DrawTexturePro(tex, 
        Rectangle(src.x + src.width - borderSize, src.y + borderSize, borderSize, innerSrc.height),
        Rectangle(dest.x + dest.width - borderSize, dest.y + borderSize, borderSize, innerDest.height),
        Vector2(0, 0), 0, tint);
    
    // 7. Bottom-left corner
    DrawTexturePro(tex, 
        Rectangle(src.x, src.y + src.height - borderSize, borderSize, borderSize),
        Rectangle(dest.x, dest.y + dest.height - borderSize, borderSize, borderSize),
        Vector2(0, 0), 0, tint);
    
    // 8. Bottom edge
    DrawTexturePro(tex, 
        Rectangle(src.x + borderSize, src.y + src.height - borderSize, innerSrc.width, borderSize),
        Rectangle(dest.x + borderSize, dest.y + dest.height - borderSize, innerDest.width, borderSize),
        Vector2(0, 0), 0, tint);
    
    // 9. Bottom-right corner
    DrawTexturePro(tex, 
        Rectangle(src.x + src.width - borderSize, src.y + src.height - borderSize, borderSize, borderSize),
        Rectangle(dest.x + dest.width - borderSize, dest.y + dest.height - borderSize, borderSize, borderSize),
        Vector2(0, 0), 0, tint);
}

void displayDialog(string[] pages, string[] choices, ref int selectedChoice, int choicePage, Font dialogFont, 
bool *showDialog, ref float textSpeed, Color dialogColor, 
Texture2D circle, Texture2D dialogBackgroundTex, Texture2D choiceWindowTex) {

    int pagesLength = cast(int)pages.length;
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    const int screenPadding = 10;
    
    // Dialog background rectangle с отступами
    Rectangle dialogRect = Rectangle(
        screenPadding, // X с отступом
        screenHeight - screenHeight / 3 - screenPadding, // Y с отступом
        screenWidth - 2 * screenPadding, // Ширина с учетом отступов
        screenHeight / 3 // Высота (без изменения)
    );
    
    // Draw dialog background with 9-slice scaling
    draw9SliceTexture(
        dialogBackgroundTex,
        dialogRect,
        DIALOG_BORDER,
        Color(255, 255, 255, 220) // Slightly transparent
    );
    
    const float textLeftMargin = 33.0f;
    const float textTopMargin = 20.0f;
    
    float marginLeft = dialogRect.x + textLeftMargin; // Отступ от левого края фона
    float marginRight = screenWidth/6.5f;
    float marginTop = dialogRect.y + textTopMargin; // Отступ от верхнего края фона
    float textWidth = dialogRect.width - textLeftMargin - marginRight;
    float fontSize = 40.0f;
    float spacing = 1.0f;
    
    string currentText = pages[currentPage];
    int textLength = cast(int)currentText.length;
    
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) && !textFullyDisplayed) {
        textDisplayProgress = textLength;
        textFullyDisplayed = true;
    }
    else if (IsKeyPressed(KeyboardKey.KEY_ENTER) && textFullyDisplayed) {
        currentPage += 1;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
    }
    else if (!textFullyDisplayed) {
        textDisplayProgress += textSpeed;
        if (textDisplayProgress >= textLength) {
            textDisplayProgress = textLength;
            textFullyDisplayed = true;
        }
    }
    
    int charsToShow = cast(int)textDisplayProgress;
    string displayedText = currentText[0 .. min(charsToShow, textLength)];
    
    string[] lines;
    string remainingText = displayedText;
    
    while (remainingText.length > 0) {
        int fitChars = 0;
        float width = 0.0f;
        
        while (fitChars < remainingText.length) {
            int nextChar = fitChars;
            while (nextChar < remainingText.length && !isWhite(remainingText[nextChar])) {
                nextChar++;
            }
            
            string word = remainingText[fitChars..nextChar];
            float wordWidth = MeasureTextEx(dialogFont, word.toStringz(), fontSize, spacing).x;
            
            if (width + wordWidth > textWidth && width > 0) {
                break;
            }
            
            width += wordWidth;
            fitChars = nextChar;
            
            while (fitChars < remainingText.length && isWhite(remainingText[fitChars])) {
                width += MeasureTextEx(dialogFont, " ".toStringz(), fontSize, spacing).x;
                fitChars++;
            }
        }
        
        if (fitChars == 0) {
            fitChars = 1;
        }
        
        lines ~= remainingText[0..fitChars];
        remainingText = remainingText[fitChars..$];
    }
    
    float lineHeight = MeasureTextEx(dialogFont, "A", fontSize, spacing).y * 1.4;
    for (int i = 0; i < lines.length; i++) {
        DrawTextEx(
            dialogFont,
            lines[i].toStringz(),
            Vector2(marginLeft+3, 3+(marginTop + i * lineHeight)),
            fontSize,
            spacing,
            Colors.BLACK
        );
        DrawTextEx(
            dialogFont,
            lines[i].toStringz(),
            Vector2(marginLeft, marginTop + i * lineHeight),
            fontSize,
            spacing,
            Colors.WHITE
        );
    }
    
    if (textFullyDisplayed && lines.length > 0) {
        // Обновляем угол вращения (например, 45 градусов в секунду)
        circleRotationAngle += 45.0f * GetFrameTime();
        if (circleRotationAngle >= 360.0f) {
            circleRotationAngle -= 360.0f;
        }

        // Получаем позицию и размер последней строки текста
        float lastLineWidth = 10 + MeasureTextEx(dialogFont, lines[$-1].toStringz(), fontSize, spacing).x;
        float lastLineY = marginTop + 20 + (lines.length - 1) * lineHeight;
        
        // Позиция круга справа от последней строки
        float circleX = marginLeft + lastLineWidth + 10; // 10 - отступ от текста
        float circleY = lastLineY;
        
        // Размер круга (можете настроить)
        float circleSize = 30.0f;
        
        Rectangle destRect = Rectangle(circleX, circleY, circleSize, circleSize);
        Rectangle sourceRect = Rectangle(0, 0, circle.width, circle.height);
        Vector2 origin = Vector2(circleSize/2, circleSize/2);
        DrawTexturePro(
            circle,
            sourceRect,
            destRect,
            origin,
            circleRotationAngle,
            Colors.WHITE
        );
    }
    
   if (currentPage == choicePage) {
        int verticalPadding = 30;
        int choiceHeight = 50;
        int choiceSpacing = 10;

        int choiceWindowWidth = screenWidth / 2;
        int choiceWindowHeight = cast(int)(verticalPadding * 2 + choices.length * choiceHeight + (choices.length - 1) * choiceSpacing);

        int choiceWindowX = (screenWidth - choiceWindowWidth) / 2;
        int choiceWindowY = (screenHeight - choiceWindowHeight) / 2;

        // Draw choice window with 9-slice scaling
        draw9SliceTexture(
            choiceWindowTex,
            Rectangle(choiceWindowX, choiceWindowY, choiceWindowWidth, choiceWindowHeight),
            CHOICE_BORDER,
            Colors.WHITE
        );

        Vector2 mousePos = GetMousePosition();
        bool mouseClicked = IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT);
        
        for (int i = 0; i < choices.length; i++) {
            Rectangle choiceRect = Rectangle(
                choiceWindowX + 40,
                choiceWindowY + verticalPadding + i * (choiceHeight + choiceSpacing),
                choiceWindowWidth - 80,
                choiceHeight
            );
            
            bool isHovered = CheckCollisionPointRec(mousePos, choiceRect);
            
            if (isHovered) {
                selectedChoice = i;
                if (mouseClicked) {
                    currentPage += 1;
                    textDisplayProgress = 0.0f;
                    textFullyDisplayed = false;
                }
            }
            
            Color color = (i == selectedChoice) ? Colors.YELLOW : (isHovered ? Colors.LIGHTGRAY : Colors.WHITE);
            
            if (isHovered || i == selectedChoice) {
                DrawRectangleRec(choiceRect, Color(60, 60, 60, 200));
            }
            
            Vector2 textSize = MeasureTextEx(dialogFont, choices[i].toStringz(), 39, spacing);
            Vector2 textPos = Vector2(
                choiceRect.x + (choiceRect.width - textSize.x) / 2,
                choiceRect.y + (choiceRect.height - textSize.y) / 2
            );
            DrawTextEx(
                dialogFont,
                choices[i].toStringz(),
                Vector2(textPos.x+3, textPos.y+3),
                39,
                spacing,
                Colors.BLACK
            );
            
            DrawTextEx(
                dialogFont,
                choices[i].toStringz(),
                textPos,
                39,
                spacing,
                color
            );
        }
        
        if (IsKeyPressed(KeyboardKey.KEY_DOWN)) {
            selectedChoice = cast(int)((selectedChoice + 1) % choices.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length);
        }
        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            currentPage += 1;
            textDisplayProgress = 0.0f;
            textFullyDisplayed = false;
        }
    }
    
    if ((IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) || IsKeyDown(KeyboardKey.KEY_RIGHT_CONTROL)) 
    && currentPage != choicePage && currentPage < pages.length) {
        currentPage += 1;
    }
    if (currentPage >= pagesLength) {
        currentPage = 0;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
        pages = [];
        textSpeed = 0.6f;
        *showDialog = false;
        return;
    }
}