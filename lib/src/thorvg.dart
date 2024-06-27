import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'thorvg_bindings_generated.dart';

/* Linking library */

const String _libName = 'thorvg';

final DynamicLibrary _dylib = () {
  if (Platform.isIOS) {
    return DynamicLibrary.open('lib$_libName.dylib');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final ThorVGFlutterBindings tvg = ThorVGFlutterBindings(_dylib);

/* ThorVG Dart */

class Thorvg {
  late ffi.Pointer<FlutterLottieAnimation> animation;
  double totalFrame = 0;
  double currentFrame = 0;
  double startTime = DateTime.now().millisecond / 1000;
  double speed = 1.0;

  // FIXME(jinny): Should be like enumeration for each status
  bool isPlaying = false;
  bool deleted = false;

  late bool animate = false;
  late bool reverse = false;
  late bool repeat = false;

  int width = 0;
  int height = 0;

  Thorvg() {
    animation = tvg.create();
  }

  Uint8List? animLoop() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    if (!update()) {
      return null;
    }

    final buffer = render();
    return buffer;
  }

  bool update() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    final duration = tvg.duration(animation);
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    currentFrame = (currentTime - startTime) / duration * totalFrame * speed;

    if (reverse) {
      currentFrame = totalFrame - currentFrame;
    }

    if ((!reverse && currentFrame >= totalFrame) ||
        (reverse && currentFrame <= 0)) {
      if (repeat) {
        currentFrame = 0;
        play();
        return true;
      }

      isPlaying = false;
      return false;
    }

    return tvg.frame(animation, currentFrame);
  }

  Uint8List? render() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    tvg.resize(animation, width, height);

    // FIXME(jinny): Sometimes it causes delay, call in threading?
    final isUpdated = tvg.update(animation);

    if (!isUpdated) {
      return null;
    }

    final buffer = tvg.render(animation);
    final canvasBuffer = buffer.asTypedList(width * height * 4);

    return canvasBuffer;
  }

  void play() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    if (!animate) {
      return;
    }

    totalFrame = tvg.totalFrame(animation);
    startTime = DateTime.now().millisecondsSinceEpoch / 1000;
    isPlaying = true;
  }

  void load(String src, int w, int h, bool animate, bool repeat, bool reverse) {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    List<int> list = utf8.encode(src);
    Uint8List bytes = Uint8List.fromList(list);

    width = w;
    height = h;
    this.animate = animate;
    this.reverse = reverse;
    this.repeat = repeat;

    tvg.create();

    final nativeBytes = bytes.toPointer().cast<Char>();
    final nativeType = 'json'.toPointer().cast<Char>();

    bool result = tvg.load(animation, nativeBytes, nativeType, width, height);

    if (!result) {
      final errorMsg = (tvg.error(animation) as Pointer<Utf8>).toDartString();
      throw Exception('Failed to load Lottie: $errorMsg');
    }

    render();

    if (animate) {
      play();
    }
  }

  void delete() {
    if (deleted) {
      return;
    }

    if (tvg.destroy(animation)) {
      deleted = true;
    }
  }
}

/* Dart Extension */

extension Uint8ListExtension on Uint8List {
  /// Converts a Uint8List to a Pointer<Uint8>.
  Pointer<Uint8> toPointer() {
    final pointer = calloc<Uint8>(length);
    for (var i = 0; i < length; i++) {
      pointer[i] = this[i];
    }
    return pointer;
  }
}

extension StringExtension on String {
  /// Converts a String to a Pointer<Uint8> (assuming ASCII characters).
  Pointer<Uint8> toPointer() {
    final units = utf8.encode(this);
    final pointer = calloc<Uint8>(units.length);
    for (var i = 0; i < units.length; i++) {
      pointer[i] = units[i];
    }
    return pointer;
  }
}
