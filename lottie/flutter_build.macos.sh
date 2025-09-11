#!/bin/bash

rm -rf build_flutter_macos

# Build for aarch64 (Apple Silicon)
rm -rf build_flutter_aarch64 libthorvg.a
mkdir build_flutter_aarch64

cd ../thorvg
meson setup -Db_lto=true -Ddefault_library=static -Dloaders="lottie, png, jpg" -Dthreads=false --cross-file ../thorvg/cross/macos_arm64.txt ../lottie/build_flutter_aarch64

cd ../lottie
ninja -C build_flutter_aarch64

cp build_flutter_aarch64/src/libthorvg.a libthorvg.a
rm -rf build_flutter_aarch64/

meson setup -Db_lto=true -Ddefault_library=static --cross-file ../thorvg/cross/macos_arm64.txt build_flutter_aarch64
ninja -C build_flutter_aarch64/

# Build for x86_64 (Intel)
rm -rf build_flutter_x86_64 libthorvg.a
mkdir build_flutter_x86_64

cd ../thorvg
meson setup -Db_lto=true -Ddefault_library=static -Dloaders="lottie, png, jpg" -Dthreads=false --cross-file ../thorvg/cross/macos_x86_64.txt ../lottie/build_flutter_x86_64

cd ../lottie
ninja -C build_flutter_x86_64

cp build_flutter_x86_64/src/libthorvg.a libthorvg.a
rm -rf build_flutter_x86_64/

meson setup -Db_lto=true -Ddefault_library=static --cross-file ../thorvg/cross/macos_x86_64.txt build_flutter_x86_64
ninja -C build_flutter_x86_64/

rm -rf libthorvg.a

mkdir build_flutter_macos

# Create Universal Binary for macOS
lipo build_flutter_x86_64/libthorvg.dylib \
build_flutter_aarch64/libthorvg.dylib \
-output build_flutter_macos/libthorvg.dylib -create

mkdir -p ../macos/Frameworks
cp build_flutter_macos/libthorvg.dylib ../macos/Frameworks/