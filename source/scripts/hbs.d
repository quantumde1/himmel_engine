module scripts.hbs;

import std.stdio;
import system.debugwriteln;
import std.file;
import std.string;
import aperture;
import std.conv;
import variables;
import std.algorithm;
import vibration;
import system.uintreader;
import system.hpf;

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
    string fontPath;
    int archiveIndex;
    int backgroundArchiveIndex;
    int characterArchiveIndex;
    int bgIndexInArchive;
    int charIndexInArchive;
    string archiveName;
}

//load_archive <index> <path(string)>
//load_bg_from_memory <index_of_archive> <index_of_file> <index_for_attachment>
//load_char_from_memory <index_of_archive> <index_of_file> <index_for_attachment>

int[] offsets; // data offsets in script
int[] sizes; // sizes of data

ReadyCommands[] commands;

// Game can load from save using this function. It executes script right to index specified in save.txt.
void saveLoader(int neededCommandIndex) {
    while (currentCommandIndex < neededCommandIndex) {
        pauseParser = false;
        executer();
    }
}

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
                    text,
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                ); // adds into array of already parsed bytecode. Moving from offset to end of line, skipping first byte because its a command byte.
                break;
            case OpCodes.SETFONT:
                // format: <opcode> <text>
                debugWriteln("SetFont");
                string pathToFont = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count])]);
                debugWriteln("acquired path: ", pathToFont);
                commands ~= ReadyCommands(
                    OpCodes.SETFONT,
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
                    "",
                    pathToFont,
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.UNLOADMUSIC:
                // <opcode>
                debugWriteln("UnloadMusic");
                commands ~= ReadyCommands(
                    OpCodes.UNLOADMUSIC,
                    
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.DRAWBACKGROUND:
                // <opcode> <scale> <X position> <Y position> <index>
                debugWriteln("DrawBackground");
                float backgroundScale = readUInt16(loadedScript, offsets[count]+sizes[count]-10)*scale; // begins with scale factor
                //float testScale = readFloat16(loadedScript, offsets[count]+sizes[count]-10)*scale;
                //debugWriteln("float test: ", testScale);
                int backgroundX = readUInt24(loadedScript, offsets[count]+sizes[count]-8); // i've taken uint24 because it has much bigger max value than uint16, but not that big as uint32 
                int backgroundY = readUInt24(loadedScript, offsets[count]+sizes[count]-5); // same as previous
                int indexOfBackground = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                debugWriteln(
                    "backgroundScale: ", backgroundScale,
                    " backgroundX: ", backgroundX,
                    " backgroundY: ", backgroundY,
                    " index: ", indexOfBackground
                );
                commands ~= ReadyCommands(
                    OpCodes.DRAWBACKGROUND,
                    
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    indexOfBackground,
                    backgroundScale,
                    Vector2(backgroundX, backgroundY),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.UNDRAWBACKGROUND:
                // <opcode> <index>
                debugWriteln("UndrawBackground");
                int indexOfBackground = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                commands ~= ReadyCommands(
                    OpCodes.UNDRAWBACKGROUND,
                    
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    indexOfBackground,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.UNLOADBACKGROUND:
                // <opcode> <index>
                debugWriteln("UnloadBackground");
                int indexOfBackground = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                commands ~= ReadyCommands(
                    OpCodes.UNLOADBACKGROUND,
                    
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    indexOfBackground,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.LOADCHARACTER:
                // <opcode> <path> <index>
                debugWriteln("LoadCharacter");
                string pathToCharacter = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count]-2)]); // We removing last two bytes because they contain index of background
                int indexOfCharacter = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                debugWriteln("Path to character: ", pathToCharacter);
                debugWriteln("index of character: ", indexOfCharacter);
                commands ~= ReadyCommands(
                    OpCodes.LOADCHARACTER,
                    
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)toStringz(pathToCharacter),
                    indexOfCharacter,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.DRAWCHARACTER:
                // <opcode> <scale> <X position> <Y position> <index>
                debugWriteln("DrawCharacter");
                float characterScale = readUInt16(loadedScript, offsets[count]+sizes[count]-10)*scale; // begins with scale factor
                int characterX = readUInt24(loadedScript, offsets[count]+sizes[count]-8); // i've taken uint24 because it has much bigger max value than uint16, but not that big as uint32 
                int characterY = readUInt24(loadedScript, offsets[count]+sizes[count]-5); // same as previous
                int indexOfCharacter = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                debugWriteln(
                    "characterScale: ", characterScale,
                    " characterX: ", characterX,
                    " characterY: ", characterY,
                    " index: ", indexOfCharacter
                );
                commands ~= ReadyCommands(
                    OpCodes.DRAWCHARACTER,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0.0, 0.0),
                    cast(char*)"",
                    indexOfCharacter,
                    characterScale,
                    Vector2(characterX, characterY),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.UNDRAWCHARACTER:
                // <opcode> <index>
                debugWriteln("UndrawCharacter");
                int indexOfCharacter = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                commands ~= ReadyCommands(
                    OpCodes.UNDRAWCHARACTER,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    indexOfCharacter,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.UNLOADCHARACTER:
                // <opcode> <index>
                debugWriteln("UnloadCharacter");
                int indexOfCharacter = readUInt16(loadedScript, offsets[count]+sizes[count]-2);
                commands ~= ReadyCommands(
                    OpCodes.UNLOADCHARACTER,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    indexOfCharacter,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.PLAYVIDEO:
                // format: <opcode> <text>
                debugWriteln("PlayVideo");
                string pathToVideo = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count])]);
                debugWriteln("acquired path: ", pathToVideo);
                commands ~= ReadyCommands(
                    OpCodes.PLAYVIDEO,
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
                    pathToVideo,
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.MAINLOOP:
                // format: <opcode>
                debugWriteln("MainLoopScript");
                commands ~= ReadyCommands(
                    OpCodes.MAINLOOP,
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
                    "",
                    "",
                    0,
                    0,
                    0,
                    0,
                    0,
                    ""
                );
                break;
            case OpCodes.LOADARCHIVE:
                // format: <opcode> <index> <string>
                debugWriteln("LoadArchive");
                string archiveName = cast(string)(loadedScript[offsets[count]+1..(offsets[count]+sizes[count])-1]);
                int archiveIndex = cast(int)loadedScript[(offsets[count]+sizes[count])-1];
                debugWriteln(
                    "archiveName: ", archiveName,
                    "\narchiveIndex: ", archiveIndex
                );
                commands ~= ReadyCommands(
                    OpCodes.LOADARCHIVE,
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
                    "",
                    "",
                    archiveIndex,
                    0,
                    0,
                    0,
                    0,
                    archiveName
                );
                break;
            case OpCodes.LOADBACKGROUNDFROMMEMORY:
                // format: <opcode> <index of archive> <index of file> <index for in-engine> 
                debugWriteln("LoadBackgroundFromMemory");
                int archiveIndex = cast(int)loadedScript[(offsets[count]+1)];
                int fileIndex = cast(int)readUInt16(loadedScript, offsets[count]+2);
                int backgroundIndex = cast(int)readUInt16(loadedScript, offsets[count]+4);
                debugWriteln(
                    "archiveIndex: ", archiveIndex,
                    "\nfileIndex: ", fileIndex,
                    "\nbackgroundIndex: ", backgroundIndex
                );
                commands ~= ReadyCommands(
                    OpCodes.LOADBACKGROUNDFROMMEMORY,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    backgroundIndex,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    archiveIndex,
                    0,
                    fileIndex,
                    0,
                    ""
                );
                break;
            case OpCodes.LOADCHARACTERFROMMEMORY:
                // format: <opcode> <index of archive> <index of file> <index for in-engine>
                debugWriteln("LoadCharacterFromMemory");
                int archiveIndex = cast(int)loadedScript[(offsets[count]+1)];
                int fileIndex = cast(int)readUInt16(loadedScript, offsets[count]+2);
                int characterIndex = cast(int)readUInt16(loadedScript, offsets[count]+4);
                debugWriteln(
                    "archiveIndex: ", archiveIndex,
                    "\nfileIndex: ", fileIndex,
                    "\ncharacterIndex: ", characterIndex
                );
                commands ~= ReadyCommands(
                    OpCodes.LOADCHARACTERFROMMEMORY,
                    cast(char*)"",
                    "",
                    cast(char*)"",
                    0,
                    0.0f,
                    Vector2(0, 0),
                    cast(char*)"",
                    characterIndex,
                    0.0f,
                    Vector2(0, 0),
                    "",
                    "",
                    "",
                    0,
                    0,
                    archiveIndex,
                    0,
                    fileIndex,
                    "",
                );
                break;
            default:
                debugWriteln("unknown: ", loadedScript[offsets[count]]);
                break;
        }
    }
    offsets.length = 0;
    sizes.length = 0;
}

void playVideo(string t) {
    return;
}

// script executer.
void executer() {
    if (currentCommandIndex >= commands.length || pauseParser == true) return;
    switch (commands[currentCommandIndex].type) {
        case OpCodes.DIALOGBOX:
            debugWriteln(commands[currentCommandIndex].message);
            messageGlobal = commands[currentCommandIndex].message; //setting text
            showDialog = true;
            break;
        case OpCodes.SETFONT:
            int[] codepoints = new int[256];
            foreach (i; 0 .. 95)
            {
                codepoints[i] = 32 + i;
            }
            
            foreach (i; 0 .. 64)
            {
                codepoints[95 + i] = 0x410 + i;
            }
            
            int fontSize = max(10, cast(int)(40 * scale));
            break;    
        case OpCodes.LOADMUSIC:
            LoadMusic(commands[currentCommandIndex].musicPath);
            break;
        case OpCodes.PLAYMUSIC:
            PlayMusic();
            break;
        case OpCodes.STOPMUSIC:
            StopMusic(); // stop music
            break;
        case OpCodes.UNLOADMUSIC:
            UnloadMusic(); // unload music
            break;
        case OpCodes.LOADBACKGROUND:
            debugWriteln(commands[currentCommandIndex].backgroundPath);
            backgroundTextures.length += 1;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture = LoadTexture(
                commands[currentCommandIndex].backgroundPath
            );
            //SetTextureFilter(backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
            break;
        case OpCodes.DRAWBACKGROUND:
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].drawTexture = true;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].width = backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture.width;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].height = backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture.height;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].x = commands[currentCommandIndex].backgroundPosition.x;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].y = commands[currentCommandIndex].backgroundPosition.y;
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].scale = commands[currentCommandIndex].backgroundScale;
            break;
        case OpCodes.LOADCHARACTER:
            debugWriteln(commands[currentCommandIndex].characterPath);
            characterTextures.length += 1;
            characterTextures[commands[currentCommandIndex].characterIndex].texture = LoadTexture(
                commands[currentCommandIndex].characterPath
            );
            break;
        case OpCodes.DRAWCHARACTER:
            characterTextures[commands[currentCommandIndex].characterIndex].drawTexture = true;
            characterTextures[commands[currentCommandIndex].characterIndex].justDrawn = true;
            int width = characterTextures[commands[currentCommandIndex].characterIndex].texture.width;
            int height = characterTextures[commands[currentCommandIndex].characterIndex].texture.height;
            characterTextures[commands[currentCommandIndex].characterIndex].width = width;
            characterTextures[commands[currentCommandIndex].characterIndex].height = height;
            characterTextures[commands[currentCommandIndex].characterIndex].x = commands[currentCommandIndex].characterPosition.x;
            characterTextures[commands[currentCommandIndex].characterIndex].y = commands[currentCommandIndex].characterPosition.y;
            characterTextures[commands[currentCommandIndex].characterIndex].scale = commands[currentCommandIndex].characterScale;
            break;
        case OpCodes.UNDRAWBACKGROUND:
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].drawTexture = false;
            break;
        case OpCodes.UNLOADBACKGROUND:
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].drawTexture = false;
            UnloadTexture(backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture);
            break;
        case OpCodes.UNDRAWCHARACTER:
            characterTextures[commands[currentCommandIndex].characterIndex].drawTexture = false;
            break;
        case OpCodes.UNLOADCHARACTER:
            characterTextures[commands[currentCommandIndex].characterIndex].drawTexture = false;
            UnloadTexture(characterTextures[commands[currentCommandIndex].characterIndex].texture);
            break;
        case OpCodes.PLAYVIDEO:
            playVideo(commands[currentCommandIndex].videoPath);
            break;
        case OpCodes.MAINLOOP:
            debugWriteln("mainloop enter");
            mainLoopScript = true;
            return;
        case OpCodes.LOADARCHIVE:
            int indexOfArchive = commands[currentCommandIndex].archiveIndex;
            string archiveName = commands[currentCommandIndex].archiveName;
            parsedChunks.length += 1;
            archivesNames.length += 1;
            parsedChunks[indexOfArchive] ~= parseArchive(archiveName);
            archivesNames[indexOfArchive] ~= archiveName;
            break;
        case OpCodes.LOADBACKGROUNDFROMMEMORY:
            int indexOfArchive = commands[currentCommandIndex].backgroundArchiveIndex;
            int bgIndexInArchive = commands[currentCommandIndex].bgIndexInArchive;
            ubyte[] backgroundFile = loadFileFromHPF(archivesNames[indexOfArchive], parsedChunks[indexOfArchive], bgIndexInArchive);
            backgroundTextures.length += 1;
            debugWriteln(backgroundFile.length);
            backgroundTextures[commands[currentCommandIndex].backgroundIndex].texture = LoadTextureFromMemory(
                backgroundFile.ptr, backgroundFile.length
            );
            break;
        case OpCodes.LOADCHARACTERFROMMEMORY:
            int indexOfArchive = commands[currentCommandIndex].characterArchiveIndex;
            int charIndexInArchive = commands[currentCommandIndex].charIndexInArchive;
            characterTextures.length += 1;
            ubyte[] characterFile = loadFileFromHPF(archivesNames[indexOfArchive], parsedChunks[indexOfArchive], charIndexInArchive);
            debugWriteln(characterFile.length);
            characterTextures[commands[currentCommandIndex].characterIndex].texture = LoadTextureFromMemory(
                characterFile.ptr, characterFile.length
            );
            break;
        default:
            break;
    }
    currentCommandIndex = currentCommandIndex + 1;
}