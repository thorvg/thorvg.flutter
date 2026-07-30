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

import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:thorvg/src/thorvg.dart' as module;
import 'package:thorvg/src/utils.dart';
import 'package:thorvg/src/view.dart';

class Svg extends TvgView {
  const Svg({
    super.key,
    required super.data,
    required super.width,
    required super.height,
    super.onLoaded,
  });

  static Svg asset(
    String name, {
    Key? key,
    double? width,
    double? height,
    AssetBundle? bundle,
    String? package,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Svg(
      key: key,
      data: parseAsset(name, bundle, package),
      width: width ?? 0,
      height: height ?? 0,
      onLoaded: onLoaded,
    );
  }

  static Svg file(
    io.File file, {
    Key? key,
    double? width,
    double? height,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Svg(
      key: key,
      data: parseFile(file),
      width: width ?? 0,
      height: height ?? 0,
      onLoaded: onLoaded,
    );
  }

  static Svg memory(
    Uint8List bytes, {
    Key? key,
    double? width,
    double? height,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Svg(
      key: key,
      data: parseMemory(bytes),
      width: width ?? 0,
      height: height ?? 0,
      onLoaded: onLoaded,
    );
  }

  static Svg network(
    String src, {
    Key? key,
    double? width,
    double? height,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Svg(
      key: key,
      data: parseSrc(src),
      width: width ?? 0,
      height: height ?? 0,
      onLoaded: onLoaded,
    );
  }

  @override
  State createState() => _State();
}

class _State extends TvgViewState<Svg> {
  @override
  bool tvgLoad() {
    try {
      tvg!.load(data, 'svg', 0, 0);

      final size = tvg!.getSize();
      updatePictureSize(size[0].toInt(), size[1].toInt());
    } catch (err) {
      setError(err);
      return false;
    }

    updateCanvasSize();

    return true;
  }

  @override
  void start() {
    _tvgRender();
  }

  @override
  void onDprChanged() {
    _tvgRender();
  }

  void _tvgRender() async {
    try {
      tvg!.resize(renderWidth.toInt(), renderHeight.toInt());

      final buffer = tvg!.render();
      if (buffer == null) return;

      await updateImage(buffer);
    } catch (err) {
      setError(err);
    }
  }
}
