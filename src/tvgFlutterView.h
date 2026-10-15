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

#include <stdint.h>
#include <stdbool.h>

typedef struct _FlutterView FlutterView;

#if defined(__GNUC__)
#define TVG_FLUTTER_EXPORT __attribute__((visibility("default")))
#else
#define TVG_FLUTTER_EXPORT
#endif

#ifdef __cplusplus
extern "C"
{
#endif


TVG_FLUTTER_EXPORT FlutterView* create();
TVG_FLUTTER_EXPORT bool destroy(FlutterView* view);
TVG_FLUTTER_EXPORT const char* error(FlutterView* view);
TVG_FLUTTER_EXPORT float* size(FlutterView* view);
TVG_FLUTTER_EXPORT float duration(FlutterView* view);
TVG_FLUTTER_EXPORT float totalFrame(FlutterView* view);
TVG_FLUTTER_EXPORT float curFrame(FlutterView* view);
TVG_FLUTTER_EXPORT void resize(FlutterView* view, int w, int h);
TVG_FLUTTER_EXPORT bool load(FlutterView* view, char* data, char* mimetype, int width, int height);
TVG_FLUTTER_EXPORT uint8_t* render(FlutterView* view);
TVG_FLUTTER_EXPORT bool frame(FlutterView* view, float no);
TVG_FLUTTER_EXPORT bool update(FlutterView* view);


#ifdef __cplusplus
}
#endif
