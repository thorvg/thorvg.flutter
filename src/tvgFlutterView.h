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

#ifdef __cplusplus
extern "C"
{
#endif


FlutterView* create();
bool destroy(FlutterView* view);
const char* error(FlutterView* view);
float* size(FlutterView* view);
float duration(FlutterView* view);
float totalFrame(FlutterView* view);
float curFrame(FlutterView* view);
void resize(FlutterView* view, int w, int h);
bool load(FlutterView* view, char* data, char* mimetype, int width, int height);
uint8_t* render(FlutterView* view);
bool frame(FlutterView* view, float no);
bool update(FlutterView* view);


#ifdef __cplusplus
}
#endif
