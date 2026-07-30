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

#include <thorvg.h>
#include "tvgFlutterView.h"

using namespace std;
using namespace tvg;

static const char* NoError = "None";

class __attribute__((visibility("default"))) TvgView
{
public:
    ~TvgView()
    {
        free(buffer);
        Initializer::term();
    }

    static TvgView* create()
    {
        return new TvgView();
    }

    bool load(char* data, char* mimetype, int width, int height)
    {
        errorMsg = NoError;

        if (!canvas) return false;

        if (data != nullptr && data[0] == '\0')
        {
            errorMsg = "Invalid data";
            return false;
        }

        canvas->remove();

        delete(animation);
        animation = Animation::gen();

        if (animation->picture()->load(data, strlen(data), mimetype, "", true) != Result::Success)
        {
            errorMsg = "load() fail";
            return false;
        }

        animation->picture()->size(&psize[0], &psize[1]);

        /* need to reset size to calculate scale in Picture.size internally before calling resize() */
        this->width = 0;
        this->height = 0;

        resize(width, height);

        if (canvas->add(animation->picture()) != Result::Success)
        {
            errorMsg = "add() fail";
            return false;
        }

        updated = true;

        return true;
    }

    bool update()
    {
        if (!updated) return true;

        errorMsg = NoError;

        if (canvas->update() != Result::Success)
        {
            errorMsg = "update() fail";
            return false;
        }

        return true;
    }

    uint8_t* render()
    {
        errorMsg = NoError;

        if (!canvas || !animation)
            return nullptr;

        if (!updated)
            return buffer;

        if (canvas->draw(true) != Result::Success)
        {
            errorMsg = "draw() fail";
            return nullptr;
        }

        canvas->sync();

        updated = false;

        return buffer;
    }

    float* size()
    {
        return psize;
    }

    void resize(int w, int h)
    {
        if (!canvas || !animation) return;
        if (width == w && height == h) return;

        canvas->sync();

        width = w;
        height = h;

        buffer = (uint8_t*)realloc(buffer, width * height * sizeof(uint32_t));
        canvas->target((uint32_t*)buffer, width, width, height, ColorSpace::ABGR8888S);

        float scale;
        float shiftX = 0.0f, shiftY = 0.0f;
        if (psize[0] > psize[1])
        {
            scale = width / psize[0];
            shiftY = (height - psize[1] * scale) * 0.5f;
        }
        else
        {
            scale = height / psize[1];
            shiftX = (width - psize[0] * scale) * 0.5f;
        }
        animation->picture()->scale(scale);
        animation->picture()->translate(shiftX, shiftY);

        updated = true;
    }

    float duration()
    {
        if (!canvas || !animation) return 0;
        return animation->duration();
    }

    float totalFrame()
    {
        if (!canvas || !animation) return 0;
        return animation->totalFrame();
    }

    float curFrame()
    {
        if (!canvas || !animation) return 0;
        return animation->curFrame();
    }

    bool frame(float no)
    {
        if (!canvas || !animation) return false;
        if (animation->frame(no) == Result::Success)
        {
            updated = true;
        }
        return true;
    }

    const char* error()
    {
        return errorMsg;
    }

private:
    explicit TvgView()
    {
        errorMsg = NoError;

        if (Initializer::init(0) != Result::Success)
        {
            errorMsg = "init() fail";
            return;
        }

        canvas = SwCanvas::gen(EngineOption::None);
        if (!canvas) errorMsg = "Invalid canvas";

        animation = Animation::gen();
        if (!animation) errorMsg = "Invalid animation";
    }

private:
    const char* errorMsg;
    SwCanvas* canvas = nullptr;
    Animation* animation = nullptr;
    uint8_t* buffer = nullptr;
    uint32_t width = 0;
    uint32_t height = 0;
    float psize[2]; // picture size
    bool updated = false;
};

#ifdef __cplusplus
extern "C"
{
#endif

    FlutterView* create()
    {
        return (FlutterView*)TvgView::create();
    }

    bool destroy(FlutterView* view)
    {
        if (!view) return false;
        delete (reinterpret_cast<TvgView*>(view));
        return true;
    }

    bool load(FlutterView* view, char* data, char* mimetype, int width, int height)
    {
        return reinterpret_cast<TvgView*>(view)->load(data, mimetype, width, height);
    }

    bool update(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->update();
    }

    uint8_t* render(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->render();
    }

    float* size(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->size();
    }

    void resize(FlutterView* view, int w, int h)
    {
        return reinterpret_cast<TvgView*>(view)->resize(w, h);
    }

    float duration(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->duration();
    }

    float totalFrame(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->totalFrame();
    }

    float curFrame(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->curFrame();
    }

    bool frame(FlutterView* view, float no)
    {
        return reinterpret_cast<TvgView*>(view)->frame(no);
    }

    const char* error(FlutterView* view)
    {
        return reinterpret_cast<TvgView*>(view)->error();
    }

#ifdef __cplusplus
}
#endif
