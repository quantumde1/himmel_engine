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
            "script": "SCRIPT:",
            "title": "TITLE:",
            "icon": "ICON:",
            "dialog_end_indicator": "DIALOG_END_INDICATOR:",
            "dialog_box": "DIALOG_BOX:",
            "choice_box": "CHOICE_BOX:",
            "fallback_font": "FALLBACK_FONT:"
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

SystemSettings loadSettingsFromConfigFile()
{
    return SystemSettings(
        parseConf!"script"("conf/settings.conf"),
        parseConf!"title"("conf/settings.conf"),
        parseConf!"icon"("conf/settings.conf"),
        parseConf!"dialog_end_indicator"("conf/settings.conf"),
        parseConf!"dialog_box"("conf/settings.conf"),
        parseConf!"choice_box"("conf/settings.conf"),
        parseConf!"fallback_font"("conf/settings.conf")
    );
}