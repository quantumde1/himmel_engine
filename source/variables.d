// quantumde1 developed software, licensed under MIT license.
module variables;

import std.typecons;
import aperture;
import system.debugwriteln;

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

struct ParsedChunk {
    int offset;
    int length;
}

enum OpCodes {
    NOP = 0x00,
    DIALOGBOX = 0x01,
    LOADBACKGROUND = 0x02,
    DRAWBACKGROUND = 0x03,
    LOADCHARACTER = 0x04,
    DRAWCHARACTER = 0x05,
    PLAYVIDEO = 0x06,
    LOADMUSIC = 0x07,
    PLAYMUSIC = 0x08,
    STOPMUSIC = 0x09,
    UNLOADMUSIC = 0x10,
    PLAYSFX = 0x11,
    UNDRAWBACKGROUND = 0x12,
    UNLOADBACKGROUND = 0x13,
    UNDRAWCHARACTER = 0x14,
    UNLOADCHARACTER = 0x15,
    SETFONT = 0x16,
    MAINLOOP = 0x17,
    ENDLOOP = 0x18,
    ADD = 0x19,
    SUB = 0x20,
    MUL = 0x21,
    DIV = 0x22,
    SET = 0x23,
    PRINT = 0x24,
    GOTO = 0x25,
    ENDIF = 0x26,
    LOADBACKGROUNDFROMMEMORY = 0x27,
    LOADCHARACTERFROMMEMORY = 0x28,
    LOADMUSICFROMMEMORY = 0x29,
    LOADARCHIVE = 0x30,
    IF = 0x31,
    VARIABLESIF = 0x32,
    ENDCOMMAND = 0xFF,
}

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
    Texture texture;
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

TextureEngine[] characterTextures;

TextureEngine[] backgroundTextures;

SystemSettings systemSettings;

//Font textFont;

//Music music;

/* booleans */

bool playAnimation = false;

bool videoFinished = false;

bool isCameraMoving = false;

bool showDialog = false;

bool isTextFullyDisplayed = false;

bool pauseParser = false;

bool mainLoopScript = false;

/* strings */

string messageGlobal;

string[] choices;

string hbsFirstExec;


/* floats */

float baseWidth;

float baseHeight;

float frameDuration = 0.016f;

float typingSpeed = 0.6f;

float scale = 1.0f;

/* textures */

Texture[] framesUI;

Texture dialogBackgroundTex;

Texture circle;

/* integer values */

int button;

int selectedChoice = 0;

int choicePage = -1;

int currentFrame = 0;

int currentChoiceCharIndex = 0;

int currentGameState = 1;

int currentCommandIndex = 0;

int[255] scriptVariables;

/* ubyte values */

ubyte animationAlpha = 127;

/* archives */

ParsedChunk[][] parsedChunks;
string[] archivesNames;