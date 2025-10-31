# Himmel Engine
![image info](screen.png)
Himmel(equal to Heaven, but in German) is an engine for Visual Novels, written using Dlang and Lua.

## Getting Started

### Getting needed components

Build system currently assumes POSIX like system. For building, you need first install next components on:

1. __FreeBSD:__
```
sudo pkg install ldc vlc dub lua53
```

2. __Alpine:__
```
doas apk add ldc2 dub vlc-dev vlc lua5.3-dev 
```

3. __Debian:__
```
sudo apt install dub ldc libvlc-dev liblua5.3-dev vlc lua5.3 build-essential
```

Next, run
```./build.sh```
. Everything will be done automatically!

## Features

Engine scripts are written in Lua with some raylib direct bindings as well as some custom functions written for visual novels

- Drawing, loading, unloading and stop drawing character and background textures
- Camera zooming to specific coordinates
- Dialog box with multiple pages and choices, with configurable design using png background 40x32 images
- Custom fonts(PNG format from XNA, ttf, otf)
- Very flexible API with direct bindings from raylib, which allows to create interesting UI
- Graphical effects from multiple PNG images
- Resolution of development, end-user resolution, fullscreen, window name, icon, menu scripts and first game script.

## TODO

- Adding lipsync as a feature
- Adding savestates in-engine

## Documentation

You can see documentation on Himmel's [wiki](https://underlevel.ddns.net/git/quantumde1/Himmel_Engine/wiki) page. It contains cheatsheet and some useful examples for getting started with development.

## License

raylib([raylib.com](https://raylib.com)) uses zlib/libpng license

himmel engine uses MIT license

VLC([videolan.org](https://videolan.org)) uses LGPL license

lua([lua.org](https://www.lua.org)) uses MIT license