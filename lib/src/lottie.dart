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

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:thorvg/src/thorvg.dart' as module;
import 'package:thorvg/src/utils.dart';

class Lottie extends StatefulWidget {
  final Future<String> data;
  final double width;
  final double height;

  final bool animate;
  final bool repeat;
  final bool reverse;

  final void Function(module.Thorvg)? onLoaded;

  const Lottie({
    Key? key,
    required this.data,
    required this.width,
    required this.height,
    required this.animate,
    required this.repeat,
    required this.reverse,
    this.onLoaded,
  }) : super(key: key);

  static Lottie asset(
    String name, {
    Key? key,
    double? width,
    double? height,
    bool? animate,
    bool? repeat,
    bool? reverse,
    AssetBundle? bundle,
    String? package,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Lottie(
      key: key,
      data: parseAsset(name, bundle, package),
      width: width ?? 0,
      height: height ?? 0,
      animate: animate ?? true,
      repeat: repeat ?? true,
      reverse: reverse ?? false,
      onLoaded: onLoaded,
    );
  }

  static Lottie file(
    io.File file, {
    Key? key,
    double? width,
    double? height,
    bool? animate,
    bool? repeat,
    bool? reverse,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Lottie(
      key: key,
      data: parseFile(file),
      width: width ?? 0,
      height: height ?? 0,
      animate: animate ?? true,
      repeat: repeat ?? true,
      reverse: reverse ?? false,
      onLoaded: onLoaded,
    );
  }

  static Lottie memory(
    Uint8List bytes, {
    Key? key,
    double? width,
    double? height,
    bool? animate,
    bool? repeat,
    bool? reverse,
    void Function(module.Thorvg)? onLoaded,
  }) {
    return Lottie(
      key: key,
      data: parseMemory(bytes),
      width: width ?? 0,
      height: height ?? 0,
      animate: animate ?? true,
      repeat: repeat ?? true,
      reverse: reverse ?? false,
      onLoaded: onLoaded,
    );
  }

  static Lottie network(String src,
      {Key? key,
      double? width,
      double? height,
      bool? animate,
      bool? repeat,
      bool? reverse,
      void Function(module.Thorvg)? onLoaded}) {
    return Lottie(
        key: key,
        data: parseSrc(src),
        width: width ?? 0,
        height: height ?? 0,
        animate: animate ?? true,
        repeat: repeat ?? true,
        reverse: reverse ?? false,
        onLoaded: onLoaded);
  }

  @override
  State createState() => _State();
}

class _State extends State<Lottie> {
  module.Thorvg? tvg;
  ui.Image? img;
  int? _frameCallbackId;

  String data = "";
  String errorMsg = "";

  // Canvas size
  double width = 0;
  double height = 0;

  // Original size (lottie)
  int lottieWidth = 0;
  int lottieHeight = 0;

  // dpr
  double dpr = 1.0;

  // Render size (calculated)
  double get renderWidth =>
      (lottieWidth > width ? width : lottieWidth).toDouble() * dpr;
  double get renderHeight =>
      (lottieHeight > height ? height : lottieHeight).toDouble() * dpr;

  bool _constraintChecked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void reassemble() {
    super.reassemble();

    if (tvg == null) {
      setState(() {
        errorMsg = "Thorvg module has not been initialized";
      });
      return;
    }

    setState(() {
      errorMsg = "";
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _unscheduleTick();

      _loadData();
      _updateLottieSize();
      _updateCanvasSize();
      _tvgLoad();

      _scheduleTick();
    });
  }

  @override
  void dispose() {
    super.dispose();

    _unscheduleTick();
    tvg!.delete();
  }

  void _updateLottieSize() {
    final info = jsonDecode(data);

    setState(() {
      lottieWidth = info['w'] ?? widget.width;
      lottieHeight = info['h'] ?? widget.height;
    });
  }

  void _updateCanvasSize() {
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

  /* TVG function wrapper
    * Has `_tvg` prefix
    * Should check error and update error message
  */
  void _tvgLoad() {
    try {
      tvg!.load(data, renderWidth.toInt(), renderHeight.toInt(), widget.animate,
          widget.repeat, widget.reverse);
    } catch (err) {
      setState(() {
        errorMsg = err.toString();
      });
    }
  }

  void _tvgResize() {
    tvg!.resize(renderWidth.toInt(), renderHeight.toInt());
  }

  Uint8List? _tvgAnimLoop() {
    try {
      return tvg!.animLoop();
    } catch (err) {
      setState(() {
        errorMsg = err.toString();
      });
    }
    return null;
  }

  Future _loadData() async {
    try {
      data = await widget.data;
    } catch (err) {
      setState(() {
        errorMsg = err.toString();
      });
    }
  }

  void _scheduleTick() {
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _unscheduleTick() {
    if (_frameCallbackId == null) {
      return;
    }

    SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
    _frameCallbackId = null;
  }

  void _tick(Duration timestamp) async {
    _scheduleTick();

    final buffer = _tvgAnimLoop();
    if (buffer == null) {
      return;
    }

    final image =
        await decodeImage(buffer, renderWidth.toInt(), renderHeight.toInt());
    setState(() {
      img = image;
    });
  }

  void _load() async {
    await _loadData();
    if (data.isEmpty) return;

    _updateLottieSize();
    _updateCanvasSize();

    tvg ??= module.Thorvg();
    _tvgLoad();

    if (widget.onLoaded != null) {
      widget.onLoaded!(tvg!);
    }

    _scheduleTick();
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
      return Container();
    }

    // Apply DPR to balance rendering quality and performance
    final deviceDpr = 1 + (MediaQuery.of(context).devicePixelRatio - 1) * 0.75;
    if (dpr != deviceDpr) {
      dpr = deviceDpr;
      _tvgResize();
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
  TVGCanvas({
    required this.image,
    required this.width,
    required this.height,
    required this.renderWidth,
    required this.renderHeight,
    this.fit = BoxFit.none,
    this.alignment = Alignment.center,
  });

  double width;
  double height;

  double renderWidth;
  double renderHeight;

  ui.Image image;

  BoxFit fit;
  Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final left = (width - renderWidth) / 2;
    final top = (height - renderHeight) / 2;

    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(left, top, renderWidth, renderHeight),
      image: image,
      fit: fit,
      alignment: alignment,
    );
  }

  @override
  bool shouldRepaint(TVGCanvas oldDelegate) {
    return image != oldDelegate.image ||
        fit != oldDelegate.fit ||
        alignment != oldDelegate.alignment;
  }
}
