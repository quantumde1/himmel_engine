// quantumde1 developed software, licensed under MIT license.
module variables;

import std.typecons;
import raylib;
import bindbc.lua;
import system.abstraction;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

void resetAllScriptValues() {
    debugWriteln("Resetting all values!");
    selectedChoice = 0;
    foreach (i; 0..characterTextures.length)
    {
        characterTextures[i].drawTexture = false;
        UnloadTexture(characterTextures[i].texture);
    }
    foreach (i; 0..backgroundTextures.length)
    {
        backgroundTextures[i].drawTexture = false;
        UnloadTexture(backgroundTextures[i].texture);
    }
    characterTextures = [];
    backgroundTextures = [];
}

/* system */

struct FadeEffect {
    float alpha = 0.0f;
    float targetAlpha = 0.0f;
    float fadeSpeed = 9.0f;
    bool isFading = false;
}

struct SystemSettings {
    int sound_state;
    char right_button;
    char left_button;
    char back_button;
    char forward_button;
    char dialog_button;
    char opmenu_button;
    string script_path;
}

struct TextureEngine {
    bool drawTexture;
    bool justDrawn;
    float width;
    float height;
    float x;
    float y;
    Texture2D texture;
    float scale;
}

enum GameState {
    MainMenu = 1,
    InGame = 2,
    Exit = 3
}

enum EngineExitCodes {
    EXIT_FILE_NOT_FOUND = 2,
    EXIT_SCRIPT_ERROR = 3,
    EXIT_OK = 0,
}

Camera2D camera;

TextureEngine[] characterTextures;

TextureEngine[] backgroundTextures;

SystemSettings systemSettings;

int currentGameState = 1;

Font textFont;

Music music;

Color dialogColor;

FadeEffect[] characterFades;

FadeEffect[] backgroundFades;

FadeEffect dialogFade;

/* booleans */

bool hintNeeded = false;

bool playAnimation = false;

bool audioEnabled = false;

bool sfxEnabled = false;

bool fullscreenEnabled = true;

bool luaReload = true;

bool videoFinished = false;

bool neededDraw2D = false;

bool isCameraMoving = false;

bool neededCharacterDrawing = false;

bool showDialog = false;

bool isTextFullyDisplayed = false;


/* strings */

string ver = "1.1.8";

string[] messageGlobal;

string[] choices;

string[] backlogText;

string luaExec;

string usedLang = "english";

char* musicPath;


/* floats */

float cameraTargetX = 0;

float cameraTargetY = 0;

float cameraTargetZoom = 1.0f;

float cameraMoveSpeed = 5.0f;

float frameDuration = 0.016f;

float typingSpeed = 0.6f;


/* textures */

Texture2D[] framesUI;

Texture2D dialogBackgroundTex;

Texture2D choiceWindowTex;

Texture2D circle;

/* integer values */

int button;

int selectedChoice = 0;

int choicePage = -1;

int currentFrame = 0;

int currentChoiceCharIndex = 0;


/* lua */

lua_State* L;