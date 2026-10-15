/*
 * Copyright (c) 2026 ThorVG project. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../thorvg_bindings_generated.dart' as gen;

/* Linking library */

const String _libName = 'thorvg';

final DynamicLibrary _dylib = () {
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

gen.ThorVGFlutterBindings? _bindings;

gen.ThorVGFlutterBindings _load() =>
    _bindings ??= gen.ThorVGFlutterBindings(_dylib);

gen.ThorVGFlutterBindings get _tvg => _load();

/* Bindings */

typedef FlutterView = Pointer<gen.FlutterView>;

class ThorVGFlutterBindings {
  Future<void> init() async {
    _load();
  }

  FlutterView create() => _tvg.create();

  bool destroy(FlutterView view) => _tvg.destroy(view);

  String error(FlutterView view) =>
      _tvg.error(view).cast<Utf8>().toDartString();

  List<double> size(FlutterView view) {
    final psize = _tvg.size(view);
    return [psize[0], psize[1]];
  }

  double duration(FlutterView view) => _tvg.duration(view);

  double totalFrame(FlutterView view) => _tvg.totalFrame(view);

  double curFrame(FlutterView view) => _tvg.curFrame(view);

  void resize(FlutterView view, int w, int h) => _tvg.resize(view, w, h);

  bool load(
      FlutterView view, String data, String mimetype, int width, int height) {
    final nativeData = data.toNativeUtf8().cast<Char>();
    final nativeType = mimetype.toNativeUtf8().cast<Char>();

    try {
      return _tvg.load(view, nativeData, nativeType, width, height);
    } finally {
      calloc.free(nativeData);
      calloc.free(nativeType);
    }
  }

  Uint8List? render(FlutterView view, int width, int height) {
    final buffer = _tvg.render(view);
    if (buffer == nullptr) return null;

    return buffer.asTypedList(width * height * 4);
  }

  bool frame(FlutterView view, double no) => _tvg.frame(view, no);

  bool update(FlutterView view) => _tvg.update(view);
}

/* Network */

Future<String> fetchSrc(Uri url) async {
  HttpClient httpClient = HttpClient();
  String errorMsg = '';

  try {
    final request = await httpClient.getUrl(url);
    final response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      return await response.transform(utf8.decoder).join();
    } else {
      errorMsg = 'Failed to load data. Error: ${response.statusCode}';
    }
  } catch (error) {
    errorMsg = 'Failed to load data. Error: $error';
  } finally {
    httpClient.close();
  }

  throw Exception(errorMsg);
}
