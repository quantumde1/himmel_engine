module system.config;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;
import system.abstraction;

nothrow auto parseConf(string type)(string filename)
{
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();
        
        static immutable typeMap = [
            "sound": "SOUND:",
            "backward": "BACKWARD:",
            "forward": "FORWARD:",
            "right": "RIGHT:",
            "left": "LEFT:",
            "dialog": "DIALOG:",
            "opmenu": "OPMENU:",
            "script": "SCRIPT:"
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
                    
                    static if (type == "sound") {
                        return value.to!int();
                    } else static if (type == "script") {
                        return value;
                    } else {
                        return value.front.to!char();
                    }
                }
            }
        }
    }
    catch (Exception e)
    {
        debugWriteln(e.msg);
    }
    
    static if (type == "sound") {
        return 0;
    } else static if (type == "script") {
        return "";
    } else {
        return 'E';
    }
}

SystemSettings loadSettingsFromConfigFile()
{
    return SystemSettings(
        parseConf!"sound"("conf/settings.conf"),      // int
        parseConf!"right"("conf/settings.conf"),     // char
        parseConf!"left"("conf/settings.conf"),       // char
        parseConf!"backward"("conf/settings.conf"),   // char
        parseConf!"forward"("conf/settings.conf"),    // char
        parseConf!"dialog"("conf/settings.conf"),     // char
        parseConf!"opmenu"("conf/settings.conf"),     // char
        parseConf!"script"("conf/settings.conf")     // string
    );
}