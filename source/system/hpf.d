module system.hpf;

import system.debugwriteln;
import system.uintreader;
import std.string;
import std.conv;
import std.stdio;
import variables;

// not ready for use yet

ParsedChunk[] parseArchive(string filename) {
    ParsedChunk[] parsedChunks;
    auto archive = File(filename, "rb");
    ubyte[] offsetsChunkLengthUbyte = new ubyte[4];
    archive.rawRead(offsetsChunkLengthUbyte);
    debugWriteln(offsetsChunkLengthUbyte); // debug
    int offsetsChunkLength = readUInt32(offsetsChunkLengthUbyte, 0);
    debugWriteln("int repres: ", offsetsChunkLength);
    ubyte[] chunks = new ubyte[offsetsChunkLength];
    archive.rawRead(chunks);
    int currentOffset = 0;
    while (readUInt32(chunks, currentOffset) != 0xFFFFFFFF) {
        parsedChunks ~= ParsedChunk(
            cast(int)readUInt32(chunks, currentOffset),
            cast(int)readUInt32(chunks, currentOffset+4)
        );
        currentOffset+=8;
    }
    return parsedChunks;
}

ubyte[] loadFileFromHPF(string filename, ParsedChunk[] parsedChunks, int fileIndex) {
    auto archive = File(filename, "rb");
    archive.seek(parsedChunks[fileIndex].offset);
    ubyte[] file = new ubyte[parsedChunks[fileIndex].length];
    archive.rawRead(file);
    return file;
}