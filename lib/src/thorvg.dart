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

import 'dart:typed_data';
import 'platform/platform.dart';

final ThorVGFlutterBindings tvg = ThorVGFlutterBindings();

/* ThorVG Dart */

class Thorvg {
  late FlutterView view;
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
    view = tvg.create();
  }

  /// Loads the ThorVG engine module. Must be awaited before creating [Thorvg].
  static Future<void> init() => tvg.init();

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

    final duration = tvg.duration(view);
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

    return tvg.frame(view, currentFrame);
  }

  void resize(int w, int h) {
    width = w;
    height = h;
    tvg.resize(view, width, height);
  }

  Uint8List? render() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    tvg.resize(view, width, height);

    // FIXME(jinny): Sometimes it causes delay, call in threading?
    final isUpdated = tvg.update(view);

    if (!isUpdated) {
      return null;
    }

    return tvg.render(view, width, height);
  }

  void play() {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    if (!animate) {
      return;
    }

    totalFrame = tvg.totalFrame(view);
    startTime = DateTime.now().millisecondsSinceEpoch / 1000;
    isPlaying = true;
  }

  void load(String src, String mimetype, int w, int h,
      {bool animate = false, bool repeat = false, bool reverse = false}) {
    if (deleted) {
      throw Exception('Thorvg is already deleted');
    }

    width = w;
    height = h;
    this.animate = animate;
    this.reverse = reverse;
    this.repeat = repeat;

    if (!tvg.load(view, src, mimetype, width, height)) {
      throw Exception('Failed to load: ${tvg.error(view)}');
    }

    render();

    if (animate) {
      play();
    }
  }

  List<double> getSize() {
    return tvg.size(view);
  }

  void delete() {
    if (deleted) {
      return;
    }

    if (tvg.destroy(view)) {
      deleted = true;
    }
  }
}
