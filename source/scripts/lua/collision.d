module scripts.lua.collision;

import bindbc.lua;
import raylib;
import variables;
import graphics.effects;
import std.conv;
import system.abstraction;
import system.config;
import std.string;
import std.algorithm;
import system.init;
import graphics.playback;
import std.file;
import graphics.collision;
import audio.sfx;

extern (C) nothrow int luaL_placeCollision(lua_State *L) {
    try {
        placeOBB(
            cast(int)luaL_checkinteger(L, 1),
            Vector3(
                luaL_checknumber(L, 2),
                luaL_checknumber(L, 3),
                luaL_checknumber(L, 4)
            ),
            Vector3(
                luaL_checknumber(L, 5),
                luaL_checknumber(L, 6),
                luaL_checknumber(L, 7)
            ),
            Vector3(
                luaL_checknumber(L, 8),
                luaL_checknumber(L, 9),
                luaL_checknumber(L, 10)
            ),
        );
    } catch (Exception e) {
        debugWriteln("Error placing obb: ", e.msg);
    }
    return 0;
}

extern (C) nothrow int luaL_moveCollision(lua_State *L) {
    collisions[cast(int)luaL_checkinteger(L, 1)].center = Vector3(
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3),
        luaL_checknumber(L, 4)
    );
    return 0;
}

extern (C) nothrow int luaL_removeCollision(lua_State *L) {
    collisions = collisions[0 .. cast(int)luaL_checkinteger(L, 1)] ~ collisions[cast(int)luaL_checkinteger(L, 1) .. $];
    return 0;
}

extern (C) nothrow int luaL_setPlayerCollisionIndex(lua_State *L) {
    playerCollisionIndex = cast(int)luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int luaL_drawCollisionWires(lua_State *L) {
    try {
        for (int i = 0; i < collisions.length; i++) {
            drawWireframe(collisions[i], Colors.RED);
        }
    } catch (Exception e) {
        
    }
    return 0;
}

extern (C) nothrow int luaL_checkCollision(lua_State *L) {
    try {
        for (int i = 0; i < collisions.length; i++) {
            debugWriteln("collision index check: ", i);
            bool collided = checkCollisionOBBvsOBB(collisions[playerCollisionIndex], collisions[i]);
            if (collided == true) {
                lua_pushboolean(L, true);
            }
            else lua_pushboolean(L, false);
        }
    } catch (Exception e) {

    }
    return 1;
}

extern (C) nothrow int luaL_checkCollisionIndex(lua_State *L) {
    try {
        bool collided = checkCollisionOBBvsOBB(collisions[cast(int)luaL_checkinteger(L, 1)], collisions[cast(int)luaL_checkinteger(L, 2)]);
        if (collided == true) {
            lua_pushboolean(L, true);
        }
        else lua_pushboolean(L, false);
    } catch (Exception e) {

    }
    return 1;
}