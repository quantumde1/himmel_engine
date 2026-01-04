module scripts.hbs;

import std.stdio;
import system.abstraction;
import std.file;
import std.string;
import raylib;
import std.conv;
import variables;

struct ReadyCommands {
    ubyte type;
    char* musicPath;
    string message;
    char* backgroundPath;
    int backgroundIndex;
    float backgroundScale;
    Vector2 backgroundPosition;
    char* characterPath;
    int characterIndex;
    float characterScale;
    Vector2 characterPosition;
    string videoPath;
    string sfxPath;
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
    ENDCOMMAND = 0xFF,
}

ushort readUInt16(ref ubyte[] bytes, size_t offset) {
    size_t internalCurrentPosition = offset;
    ubyte b0 = bytes[internalCurrentPosition];
    ubyte b1 = bytes[internalCurrentPosition + 1];
    ushort result = b0 | (b1 << 8);
    return result;
}

uint readUInt24(ref ubyte[] bytes, size_t offset) {
    size_t internalCurrentPosition = offset;
    uint b0 = bytes[internalCurrentPosition];
    uint b1 = bytes[internalCurrentPosition + 1];
    uint b2 = bytes[internalCurrentPosition + 2];
    uint result = b0 | (b1 << 8) | (b2 << 16);
    return result;
}

uint readUInt32(ref ubyte[] bytes, size_t offset) {
    size_t internalCurrentPosition = offset;
    uint b0 = bytes[internalCurrentPosition];
    uint b1 = bytes[internalCurrentPosition + 1];
    uint b2 = bytes[internalCurrentPosition + 2];
    uint b3 = bytes[internalCurrentPosition + 3];
    uint result = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    return result;
}

int[] offsets; // data offsets in script
int[] sizes; // sizes of data

ReadyCommands[] commands;

void loader(ref ubyte[] loadedScript) {
    /* Loads buffer with commands addresses into RAM
    first four bytes can be skipped, but they contains header(HBS) and padding byte
    then there is a jumptable
    01 23 45 67 - offset in file to opcode
    89 10 - size
    00 - end of element in jumptable
    and then will be another element... Then, 7 bytes empty and 4 bytes with 0xFF. And then commands on addresses specified in jumptables.
    */

    // Define variables.
    int currentOffset = 0;
    char* header = cast(char*)loadedScript[0..3]; // read header

    // debug.
    debugWriteln("Header: ", header.to!string);

    currentOffset += 4; // moving from beginning to start of jumptable, because header and version already parsed.
    while (readUInt32(loadedScript, currentOffset) != 0xFFFFFFFF) {
        offsets ~= readUInt32(loadedScript, currentOffset);
        debugWriteln(offsets);
        currentOffset = currentOffset + 4;
        sizes ~= readUInt16(loadedScript, currentOffset);
        currentOffset = currentOffset + 3;
        debugWriteln(currentOffset);
        if (offsets[offsets.length-1] == 0) {
            offsets.length -= 1;
            sizes.length -= 1;
            break;
        }
    }
    debugWriteln("currentOffset: ", currentOffset);
    debugWriteln("Offsets and sizes acquired, exiting: ", offsets, sizes);
}

void parser(ref ubyte[] loadedScript) {
    debugWriteln("parser running");
    for (int count = 0; count < offsets.length; count++) {
        switch (loadedScript[offsets[count]]) { // opcodes for some reason starts with +1 pointer at file
            case OpCodes.DIALOGBOX:
                // format: <opcode> <text>
                debugWriteln("DialogBox");
                string text = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count])]); // count +1 at offsets for skipping opcode
                debugWriteln("acquired text: ", text);
                commands ~= ReadyCommands(
                    OpCodes.DIALOGBOX, 
                    cast(char*)"",
                    text, cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                ); // adds into array of already parsed bytecode. Moving from offset to end of line, skipping first byte because its a command byte.
                break;
            case OpCodes.LOADMUSIC:
                // format: <opcode> <path>
                debugWriteln("LoadMusic");
                string pathToMusic = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count])]); // same as in dialogBox
                debugWriteln("acquired path to music: ", pathToMusic);
                commands ~= ReadyCommands(
                    OpCodes.LOADMUSIC,
                    cast(char*)toStringz(pathToMusic),
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                ); // same, and so on
                break;
            case OpCodes.PLAYMUSIC:
                // <opcode>
                debugWriteln("PlayMusic");
                commands ~= ReadyCommands(
                    OpCodes.PLAYMUSIC,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                );
                break;
            case OpCodes.STOPMUSIC:
                // <opcode>
                debugWriteln("StopMusic");
                commands ~= ReadyCommands(
                    OpCodes.STOPMUSIC,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                );
                break;
            case OpCodes.UNLOADMUSIC:
                // <opcode>
                debugWriteln("UnloadMusic");
                commands ~= ReadyCommands(
                    OpCodes.STOPMUSIC,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                );
                break;
            case OpCodes.LOADBACKGROUND:
                // <opcode> <path> <index>
                debugWriteln("LoadBackground");
                string pathToBackground = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count]-2)]); // We removing last two bytes because they contain index of background
                int indexOfBackground = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                debugWriteln("Path to background: ", pathToBackground);
                debugWriteln("index of background: ", indexOfBackground);
                commands ~= ReadyCommands(
                    OpCodes.LOADBACKGROUND,
                    cast(char*)"",
                    "",
                    cast(char*)toStringz(pathToBackground),
                    indexOfBackground,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    ""
                );
                break;
            case OpCodes.DRAWBACKGROUND:
                // <opcode> <scale> <X position> <Y position>
                debugWriteln("DrawBackground");
                break;
            case OpCodes.UNDRAWBACKGROUND:
                // <opcode> <index>
                debugWriteln("UndrawBackground");
                break;
            case OpCodes.UNLOADBACKGROUND:
                // <opcode> <index>
                debugWriteln("UnloadBackground");
                break;
            case OpCodes.LOADCHARACTER:
                debugWriteln("LoadCharacter");
                break;
            case OpCodes.DRAWCHARACTER:
                debugWriteln("DrawCharacter");
                break;
            case OpCodes.UNDRAWCHARACTER:
                debugWriteln("UndrawBackground");
                break;
            case OpCodes.UNLOADCHARACTER:
                debugWriteln("UnloadCharacter");
                break;
            default:
                debugWriteln("unknown: ", loadedScript[offsets[count]]);
                break;
        }
    }
    offsets.length = 0;
    sizes.length = 0;
}

int currentCommandIndex = 0;

// script executer.
void executer() {
    if (currentCommandIndex >= commands.length || pauseParser == true) return;
    switch (commands[currentCommandIndex].type) {
        case OpCodes.DIALOGBOX:
            debugWriteln(commands[currentCommandIndex].message);
            messageGlobal.length = 1; // initialization of array
            messageGlobal[0] = commands[currentCommandIndex].message; //setting text
            showDialog = true;
            break;
        case OpCodes.LOADMUSIC:
            music = LoadMusicStream(commands[currentCommandIndex].musicPath); // load music
            break;
        case OpCodes.PLAYMUSIC:
            PlayMusicStream(music); // play music
            break;
        case OpCodes.STOPMUSIC:
            StopMusicStream(music); // stop music
            break;
        case OpCodes.UNLOADMUSIC:
            UnloadMusicStream(music); // unload music
            break;
        case OpCodes.LOADBACKGROUND:
            debugWriteln(commands[currentCommandIndex].backgroundPath);
            backgroundTextures.length = 1;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture = LoadTexture(
                commands[currentCommandIndex].backgroundPath
            );
            break;
        default:
            break;
    }
    currentCommandIndex = currentCommandIndex + 1;
}