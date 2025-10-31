module system.config;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;
import system.abstraction;

nothrow string parseConf(string type, string filename) {
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();
        
        static immutable typeMap = [
            "script": "SCRIPT:",
            "menu_script": "MENU_SCRIPT:",
            "title": "TITLE:",
            "icon": "ICON:",
            "dialog_end_indicator": "DIALOG_END_INDICATOR:",
            "dialog_box": "DIALOG_BOX:",
            "fallback_font": "FALLBACK_FONT:",
            "default_screen_width": "DEV_SCREEN_WIDTH:",
            "default_screen_height": "DEV_SCREEN_HEIGHT:",
            "screen_width": "SCREEN_WIDTH:",
            "screen_height": "SCREEN_HEIGHT:",
            "default_fullscreen": "DEFAULT_FULLSCREEN:",
            "render_texture_width": "RENDER_TEXTURE_WIDTH:",
            "render_texture_height": "RENDER_TEXTURE_HEIGHT:"
        ];

        if (type in typeMap)
        {
            auto prefix = typeMap[type];
            foreach (line; config)
            {
                auto trimmedLine = strip(line);
                if (trimmedLine.startsWith(prefix))
                {
                    auto value = trimmedLine[prefix.length .. $].strip();
                    debug debugWriteln("Value for ", type, ": ", value);
                    return value;
                }
            }
        }
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    return "";
}

SystemSettings loadSettingsFromConfigFile(string confName) {
    return SystemSettings(
        parseConf("script", confName),
        parseConf("menu_script", confName),
        parseConf("title", confName),
        parseConf("icon", confName),
        parseConf("dialog_end_indicator", confName),
        parseConf("dialog_box", confName),
        parseConf("fallback_font", confName),
        parseConf("default_screen_width", confName).to!int,
        parseConf("default_screen_height", confName).to!int,
        parseConf("screen_width", confName).to!int,
        parseConf("screen_height", confName).to!int,
        parseConf("default_fullscreen", confName).to!bool,
        parseConf("render_texture_width", confName).to!int,
        parseConf("render_texture_height", confName).to!int,
    );
}