#!/bin/sh
echo 'Cloning raylib'
git clone https://github.com/quantumde1/raylib
echo 'Cloning hpff'
git clone https://github.com/quantumde1/hpff

echo 'Building raylib'
cd raylib/src && make -j$(nproc) PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED
cp ./*.so ../../
cd ../../

echo 'Building hpff'
cd hpff/ && ./build.sh && cp ./libhpff.so ../
cd ../

case "$1" in
    "release")
        dub build --build=release
    ;;
     *)
        echo 'building debug'
        dub build
    ;;
esac