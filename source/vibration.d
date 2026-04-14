extern (C) {
    int LoadMusic(const char* filename);
    //int LoadMusicFromMemory(ubyte[] data);
    int PlayMusic();
    int StopMusic();
    int UnloadMusic();
}