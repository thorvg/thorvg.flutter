# !/bin/bash

# Build for aarch64
sed -e "s|NDK|$1|g" -e "s|HOST_TAG|$2|g" -e "s|API|$3|g" ../thorvg/cross/android_aarch64.txt > /tmp/.flutter_android_cross.txt

rm -rf build_flutter_aarch64 libthorvg.a
mkdir build_flutter_aarch64

cd ../thorvg
meson setup -Db_lto=true -Ddefault_library=static -Dloaders="lottie, png, jpg" -Dextra="lottie_exp" -Dthreads=false --cross-file /tmp/.flutter_android_cross.txt ../lottie/build_flutter_aarch64

cd ../lottie
ninja -C build_flutter_aarch64

cp build_flutter_aarch64/src/libthorvg-1.a libthorvg.a
rm -rf build_flutter_aarch64/

meson setup -Db_lto=true -Ddefault_library=static --cross-file /tmp/.flutter_android_cross.txt build_flutter_aarch64
ninja -C build_flutter_aarch64/

# Build for x86_64
sed -e "s|NDK|$1|g" -e "s|HOST_TAG|$2|g" -e "s|API|$3|g" ../thorvg/cross/android_x86_64.txt > /tmp/.flutter_android_cross.txt

rm -rf build_flutter_x86_64 libthorvg.a
mkdir build_flutter_x86_64

cd ../thorvg
meson setup -Db_lto=true -Ddefault_library=static -Dloaders="lottie, png, jpg" -Dextra="lottie_exp" -Dthreads=false --cross-file /tmp/.flutter_android_cross.txt ../lottie/build_flutter_x86_64

cd ../lottie
ninja -C build_flutter_x86_64

cp build_flutter_x86_64/src/libthorvg-1.a libthorvg.a
rm -rf build_flutter_x86_64/

meson setup -Db_lto=true -Ddefault_library=static --cross-file /tmp/.flutter_android_cross.txt build_flutter_x86_64
ninja -C build_flutter_x86_64/

rm -rf libthorvg.a

# Copy the shared libraries to the Android project
mkdir -p ../android/src/main/jniLibs/arm64-v8a ../android/src/main/jniLibs/armeabi-v7a ../android/src/main/jniLibs/x86_64

cp $1/toolchains/llvm/prebuilt/$2/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ../android/src/main/jniLibs/armeabi-v7a
cp $1/toolchains/llvm/prebuilt/$2/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ../android/src/main/jniLibs/arm64-v8a
cp $1/toolchains/llvm/prebuilt/$2/sysroot/usr/lib/x86_64-linux-android/libc++_shared.so ../android/src/main/jniLibs/x86_64

cp build_flutter_aarch64/libthorvg.so ../android/src/main/jniLibs/arm64-v8a
cp build_flutter_aarch64/libthorvg.so ../android/src/main/jniLibs/armeabi-v7a
cp build_flutter_x86_64/libthorvg.so ../android/src/main/jniLibs/x86_64

ls -lrt ../android/src/main/jniLibs/*/*.so
