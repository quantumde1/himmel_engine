module dialogs.dialogbox;

import raylib;
import std.string;
import std.uni;
import std.algorithm;
import variables;

int currentPage = 0;
float textDisplayProgress = 0.0f;
bool textFullyDisplayed = false;
float circleRotationAngle = 0.0f;

string[] wrapText(string text, float maxWidth, float fontSize, float spacing = 1.0f) {
    string[] lines;
    string currentLine;
    string[] words = split(text);
    
    foreach (word; words) {
        string testLine = currentLine.empty ? word : currentLine ~ " " ~ word;
        float testWidth = MeasureTextEx(textFont, toStringz(testLine), fontSize, spacing).x;
        
        if (testWidth <= maxWidth) {
            currentLine = testLine;
        } else {
            if (!currentLine.empty) {
                lines ~= currentLine;
            }
            currentLine = word;
        }
    }
    
    if (!currentLine.empty) {
        lines ~= currentLine;
    }
    
    return lines;
}

void dialogBox() {
    if (messageGlobal.empty) {
        return;
    }
    
    float dialogHeight = systemSettings.screenHeight / 3;
    Rectangle dialogBox = Rectangle(0, systemSettings.screenHeight - dialogHeight, systemSettings.screenWidth, dialogHeight);
    Rectangle dialogBoxLine = Rectangle(
        10.0f * scale,
        systemSettings.screenHeight - dialogHeight + 10.0f * scale,
        systemSettings.screenWidth - 20.0f * scale,
        dialogHeight - 20.0f * scale
    );
    
    int totalPages = cast(int)messageGlobal.length;
    
    if (currentPage >= totalPages) {
        currentPage = totalPages - 1;
    }
    
    string currentText = messageGlobal[currentPage];
    
    DrawRectangleRounded(dialogBox, 0.03f, 16, Color(0, 0, 0, 170));
    DrawRectangleRoundedLinesEx(dialogBoxLine, 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
    
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
        if (!textFullyDisplayed) {
            textDisplayProgress = currentText.length;
            textFullyDisplayed = true;
        } else {
            if (currentPage < totalPages - 1) {
                currentPage++;
                textDisplayProgress = 0.0f;
                textFullyDisplayed = false;
            } else {
                if (choices.empty) {
                    resetDialog();
                    return;
                }
            }
        }
    } else if (!textFullyDisplayed) {
        textDisplayProgress = min(textDisplayProgress + 1.0f, cast(float)currentText.length);
        textFullyDisplayed = textDisplayProgress >= currentText.length;
    }
    
    string displayText = currentText[0..min(cast(int)textDisplayProgress, currentText.length)];
    
    float maxTextWidth = systemSettings.screenWidth - 40.0f * scale;
    float fontSize = 40.0f * scale;
    float lineHeight = 50.0f * scale;
    
    string[] wrappedLines = wrapText(displayText, maxTextWidth, fontSize);
    
    Vector2 initialTextPosition = Vector2(
        20.0f * scale,
        systemSettings.screenHeight - dialogHeight + 20.0f * scale
    );
    
    for (int i = 0; i < wrappedLines.length; i++) {
        Vector2 linePos = Vector2(
            initialTextPosition.x,
            initialTextPosition.y + i * lineHeight
        );
        DrawTextEx(textFont, toStringz(wrappedLines[i]), linePos, fontSize, 1.0f, Colors.WHITE);
    }
    
    if (!choices.empty && textFullyDisplayed && currentPage == totalPages - 1) {
        float choiceStartY = systemSettings.screenHeight - dialogHeight + 20.0f * scale + wrappedLines.length * lineHeight + 20.0f * scale;
        
        for (int i = 0; i < choices.length; i++) {
            string choiceText = choices[i];
            Vector2 choicePos = Vector2(50.0f * scale, choiceStartY + i * 60.0f * scale);
            
            if (i == selectedChoice) {
                DrawRectangle(
                    cast(int)choicePos.x - 10, 
                    cast(int)choicePos.y - 5,
                    cast(int)MeasureTextEx(textFont, toStringz(choiceText), 35.0f * scale, 1.0f).x + 20,
                    50,
                    Color(100, 54, 65, 100)
                );
            }
            
            DrawTextEx(textFont, toStringz(choiceText), choicePos, 35.0f * scale, 1.0f, 
                      i == selectedChoice ? Colors.YELLOW : Colors.WHITE);
        }
        
        if (IsKeyPressed(KeyboardKey.KEY_DOWN)) {
            selectedChoice = cast(int)((selectedChoice + 1) % choices.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length);
        }
        
        if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
            resetDialog();
            return;
        }
    }
}

void resetDialog() {
    currentPage = 0;
    textDisplayProgress = 0.0f;
    textFullyDisplayed = false;
    choices = [];
    messageGlobal = [];
    showDialog = false;
    selectedChoice = 0;
}