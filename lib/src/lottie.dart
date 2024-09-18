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

  // Render size (calculated)
  double get renderWidth =>
      (lottieWidth > width ? width : lottieWidth).toDouble();
  double get renderHeight =>
      (lottieHeight > height ? height : lottieHeight).toDouble();

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
    if (widget.width == 0 || widget.height == 0) {
      setState(() {
        width = lottieWidth.toDouble();
        height = lottieHeight.toDouble();
      });
      return;
    }

    setState(() {
      width = widget.width;
      height = widget.height;
    });
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
        width: widget.width.toDouble(),
        height: widget.height.toDouble(),
        child: ErrorWidget(errorMsg),
      );
    }

    if (img == null) {
      return Container();
    }

    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: CustomPaint(
        painter: TVGCanvas(
            width: width.toDouble(),
            height: height.toDouble(),
            lottieWidth: lottieWidth.toDouble(),
            lottieHeight: lottieHeight.toDouble(),
            renderWidth: renderWidth.toDouble(),
            renderHeight: renderHeight.toDouble(),
            image: img!),
      ),
    );
  }
}

class TVGCanvas extends CustomPainter {
  TVGCanvas(
      {required this.image,
      required this.width,
      required this.height,
      required this.lottieWidth,
      required this.lottieHeight,
      required this.renderWidth,
      required this.renderHeight});

  double width;
  double height;

  double lottieWidth;
  double lottieHeight;

  double renderWidth;
  double renderHeight;

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final left = renderWidth > width ? 0.0 : (width - renderWidth) / 2;
    final top = renderHeight > height ? 0.0 : (height - renderHeight) / 2;

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
