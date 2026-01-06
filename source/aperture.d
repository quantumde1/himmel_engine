module aperture;

struct Color {
    float r;
    float g;
    float b;
    float a;
}

struct Texture {
    uint id;
    uint list_id;
    int width;
    int height;
    int channels;
}

enum Colors {
    WHITE = Color(255, 255, 255, 255),
    BLACK = Color(0, 0, 0, 255),
    RED = Color(255, 0, 0, 255),
    GREEN = Color(0, 255, 0, 255),
    BLUE = Color(0, 0, 255, 255)
}

struct Vector2 {
    float x;
    float y;
}

extern (C) @nogc {
    nothrow {
        void SetTargetFPS(int fps);
        void DrawText(const char* text, float x, float y, float scale, Color color = Color(255, 255, 255, 255));
        float GetScreenWidth();
        float GetScreenHeight();
        void BeginDrawing();
        void EndDrawing();
        void ClearBackground(Color color);
        void InitWindow(int argc, char** argv, int width, int height, const char* title);
        void DrawRectangle(float x, float y, float width, float height, Color color = Color(255, 255, 255, 255));
        Texture LoadTexture(const char* filename);
        void DrawTexture(Texture texture, float x, float y, float scale, Color tint = Color(255, 255, 255, 255));
        void UnloadTexture(Texture texture);
        int WindowShouldClose();
        void CloseWindow();
        void PollWindowEvents();
        float GetFrameTime();
        float GetTime();
    }
}