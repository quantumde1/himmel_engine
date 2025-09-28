// quantumde1 developed software, licensed under MIT license.
module variables;

import std.typecons;
import raylib;
import bindbc.lua;
import system.abstraction;
import graphics.collision;

nothrow void resetAllScriptValues() {
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

struct SystemSettings {
    string scriptPath;
    string menuScriptPath;
    string windowTitle;
    string iconPath;
    string dialogBoxEndIndicator;
    string dialogBoxBackground;
    string fallbackFont;
    int defaultScreenWidth;
    int defaultScreenHeight;
    int screenWidth;
    int screenHeight;
    bool defaultFullscreen;
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
    Color color = Colors.WHITE;
    float alpha = 0.0f;
    float targetAlpha = 0.0f;
    float fadeSpeed = 9.0f;
    bool isFading = false;
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

Camera3D camera;

OBB[] collisions;

TextureEngine[] characterTextures;

TextureEngine[] backgroundTextures;

SystemSettings systemSettings;

Font textFont;

Music music;

/* booleans */

bool playAnimation = false;

bool luaReload = true;

bool videoFinished = false;

bool isCameraMoving = false;

bool showDialog = false;

bool isTextFullyDisplayed = false;


/* strings */

string[] messageGlobal;

string[] choices;

string luaExec;


/* floats */

float baseWidth;

float baseHeight;

float frameDuration = 0.016f;

float typingSpeed = 0.6f;

float scale = 1.0f;

float acceleration = 0.2f;

float maxVelocity = 10.0f;

float currentVelocity = 0.0f;

/* textures */

Texture2D[] framesUI;

Texture2D dialogBackgroundTex;

Texture2D circle;

/* integer values */

int button;

int selectedChoice = 0;

int choicePage = -1;

int currentGameState = 1;

int currentFrame = 0;

int currentChoiceCharIndex = 0;

int playerCollisionIndex = 0; //default, can be changed via setter function in graphics.collision

/* ubyte values */

ubyte animationAlpha = 127;


/* lua */

lua_State* L;