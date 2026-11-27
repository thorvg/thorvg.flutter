#!/bin/bash

rm -rf build_flutter_ios

cd ../thorvg
meson setup -Dloaders="lottie, svg, png, jpg" -Dextra="lottie_exp" -Dthreads=false -Dpartial=false --cross-file ./cross/ios_arm64.txt ../tool/build_flutter_ios

cd ../tool
cp build_flutter_ios/config.h ../ios/config.h
rm -rf build_flutter_ios
