/*
 * Copyright (c) 2024 - 2026 ThorVG project. All rights reserved.

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
 
import 'dart:async';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

Future<String> parseSrc(String src) async {
  if (src.startsWith('http')) {
    final url = Uri.parse(src);
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

  return src;
}

Future<String> parseAsset(
    String name, AssetBundle? bundle, String? package) async {
  final targetBundle = bundle ?? rootBundle;
  final assetKey = package == null ? name : 'packages/$package/$name';

  return await targetBundle.loadString(assetKey);
}

Future<String> parseFile(io.File file) async {
  final bytes = await file.readAsBytes();
  return String.fromCharCodes(bytes);
}

Future<String> parseMemory(Uint8List data) async {
  return String.fromCharCodes(data);
}

Future<ui.Image> decodeImage(Uint8List buffer, int width, int height) async {
  final Completer<ui.Image> completer = Completer();

  ui.decodeImageFromPixels(buffer, width, height, ui.PixelFormat.rgba8888,
      allowUpscaling: false,
      targetWidth: width,
      targetHeight: height, (result) {
    completer.complete(result);
  });

  return completer.future;
}
