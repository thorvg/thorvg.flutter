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
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thorvg/src/thorvg.dart' as module;
import 'package:thorvg/src/utils.dart';

abstract class TvgView extends StatefulWidget {
  final Future<String> data;
  final double width;
  final double height;

  final void Function(module.Thorvg)? onLoaded;

  const TvgView({
    super.key,
    required this.data,
    required this.width,
    required this.height,
    this.onLoaded,
  });
}

abstract class TvgViewState<T extends TvgView> extends State<T> {
  module.Thorvg? tvg;
  ui.Image? img;

  String data = "";
  String errorMsg = "";

  // Canvas size
  double width = 0;
  double height = 0;

  // Intrinsic size
  int pictureWidth = 0;
  int pictureHeight = 0;

  // dpr
  double dpr = 1.0;

  // Render size (calculated)
  double get renderWidth =>
      (pictureWidth > width ? width : pictureWidth).toDouble() * dpr;
  double get renderHeight =>
      (pictureHeight > height ? height : pictureHeight).toDouble() * dpr;

  bool _constraintChecked = false;
  bool tvgLoad();

  void start();

  void onDprChanged();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
    tvg?.delete();
  }

  Future<void> load() async {
    if (!await loadData()) return;
    if (data.isEmpty) return;

    tvg ??= module.Thorvg();
    if (!tvgLoad()) return;

    if (widget.onLoaded != null) {
      widget.onLoaded!(tvg!);
    }

    start();
  }

  Future<bool> loadData() async {
    try {
      data = await widget.data;
    } catch (err) {
      setError(err);
      return false;
    }
    return true;
  }

  void setError(Object err) {
    setState(() {
      errorMsg = err.toString();
    });
  }

  void updatePictureSize(int w, int h) {
    setState(() {
      pictureWidth = w;
      pictureHeight = h;
    });
  }

  void updateCanvasSize() {
    if (widget.width != 0 && widget.height != 0) {
      setState(() {
        width = widget.width;
        height = widget.height;
      });
      return;
    }

    if (!mounted || _constraintChecked) return;

    final renderBox = context.findRenderObject();
    if (renderBox is RenderBox) {
      setState(() {
        _constraintChecked = true;
        width = widget.width == 0 ? renderBox.size.width : widget.width;
        height = widget.height == 0 ? renderBox.size.height : widget.height;
      });
    }
  }

  Future<void> updateImage(Uint8List buffer) async {
    final image =
        await decodeImage(buffer, renderWidth.toInt(), renderHeight.toInt());
    setState(() {
      img = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMsg.isNotEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ErrorWidget(errorMsg),
      );
    }

    if (img == null) {
      return const SizedBox.shrink();
    }

    // Apply DPR to balance rendering quality and performance
    final deviceDpr = 1 + (MediaQuery.of(context).devicePixelRatio - 1) * 0.75;
    if (dpr != deviceDpr) {
      dpr = deviceDpr;
      onDprChanged();
    }

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Transform.scale(
        scale: 1.0 / dpr,
        child: CustomPaint(
          painter: TVGCanvas(
            width: width,
            height: height,
            renderWidth: renderWidth,
            renderHeight: renderHeight,
            image: img!,
          ),
        ),
      ),
    );
  }
}

class TVGCanvas extends CustomPainter {
  TVGCanvas(
      {required this.image,
      required this.width,
      required this.height,
      required this.renderWidth,
      required this.renderHeight});

  double width;
  double height;

  double renderWidth;
  double renderHeight;

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final left = (width - renderWidth) / 2;
    final top = (height - renderHeight) / 2;

    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(left, top, renderWidth, renderHeight),
      image: image,
      fit: BoxFit.none, //NOTE: Should make it a param
      filterQuality: FilterQuality.high, //NOTE: Should make it a param
      alignment: Alignment.center, //NOTE: Should make it a param
    );
  }

  @override
  bool shouldRepaint(TVGCanvas oldDelegate) {
    return image != oldDelegate.image;
  }
}
