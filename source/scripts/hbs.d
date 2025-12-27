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
    Music music;
    string message;
    char* backgroundPath;
    int backgroundIndex;
    char* characterPath;
    int characterIndex;
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
                debugWriteln("DialogBox");
                string text = cast(string)(loadedScript[offsets[count]+1..offsets[count]+sizes[count]]); // count +1 at offsets for skipping opcode
                debugWriteln("acquired text: ", text);
                commands ~= ReadyCommands(OpCodes.DIALOGBOX, music, text, cast(char*)"", 0, cast(char*)"", 0, "", ""); // adds into array for already parsed bytecode.
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
        default:
            break;
    }
    currentCommandIndex = currentCommandIndex + 1;
}