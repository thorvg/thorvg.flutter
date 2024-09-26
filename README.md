# ThorVG for Flutter

[![pub package](https://img.shields.io/pub/v/thorvg.svg)](https://pub.dev/packages/thorvg.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

This package provides [ThorVG](https://github.com/thorvg/thorvg) runtime for Flutter, including efficient Lottie animation support based on a native API.

> Currently, we only support Animation(Lottie) feature in this package.

## Supported Platforms

| Platform | Architecture |
| ------------- | ------------- |
| Android | arm64-v8a, armeabi-v7a, x86_64 |
| iOS | arm64, x86_64, x86_64(simulator) |

## Usage

### Animation
Lottie implementation aims to maintain the same interface as `lottie-flutter`. If you are currently using them, you can utilize the code by simply replacing the import statement with `import 'package:thorvg/thorvg.dart'`.

```dart
import 'package:thorvg/thorvg.dart';
// ...
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // Load a Lottie animation from the assets
            Lottie.asset('assets/lottie/dancing_star.json'),

            // Load a Lottie animation from a url
            Lottie.network(
              'https://lottie.host/6d7dd6e2-ab92-4e98-826a-2f8430768886/NGnHQ6brWA.json'
            ),
          ],
        ),
      ),
    );
  }
}
```

## Generate Flutter binding

If you change binding interface in these files
- `tvgFlutterLottieAnimation.h`
- `tvgFlutterLottieAnimation.cpp`

You always have to run following script:

```sh
# Run at first time
flutter pub get
# Generate bindings with ffigen
flutter pub run ffigen --config ffigen.yaml
```

You will have `./lib/src/thorvg_bindings_generated.dart`.


## Build

Specify the ThorVG version in `.gitmodules`.

```sh
[submodule "thorvg"]
  path = thorvg
  url = git@github.com:thorvg/thorvg.git
  branch = v0.14.x # Change to version you want
```

Then you can run following commands to align with that version before build.

```sh
git submodule init
git submodule update --remote
```

### Android

Android build requires NDK([LTS](https://developer.android.com/ndk/downloads#lts-downloads)), please specify following build [systems info](https://developer.android.com/ndk/guides/other_build_systems?_gl=1*19sk6gt*_up*MQ..*_ga*MTYxMjIxMTcwMi4xNzE0MTE5NTk1*_ga_6HH9YJMN9M*MTcxNDExOTU5NS4xLjAuMTcxNDExOTU5NS4wLjAuMA..#overview).

```sh
# Build for Animation(Lottie)
cd lottie
sh flutter_build.android.sh $NDK $HOST_TAG $API
```

Check whether these files are gnerated:
- `android/src/main/arm64-v8a/libthorvg.so`
- `android/src/main/armeabi-v7a/libthorvg.so`
- `android/src/main/x86_64/libthorvg.so`

### iOS
```sh
# Build for Animation(Lottie)
cd lottie
sh flutter_build.ios.sh
```

Check the file is generated:
- `ios/Frameworks/libthorvg.dylib`
