module system.debugwriteln;

import std.stdio;

nothrow void debugWriteln(A...)(A args)
{
    debug
    {
        try
        {
            writeln("INFO: ENGINE: ", args);
        }
        catch (Exception e)
        {
            debugWriteln(e.msg);
        }
    }
}