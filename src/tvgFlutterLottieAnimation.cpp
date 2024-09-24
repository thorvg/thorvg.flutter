#include <thorvg.h>
#include "tvgFlutterLottieAnimation.h"

using namespace std;
using namespace tvg;

static const char* NoError = "None";

class __attribute__((visibility("default"))) TvgLottieAnimation
{
public:
    ~TvgLottieAnimation()
    {
        free(buffer);
        Initializer::term(CanvasEngine::Sw);
    }

    static unique_ptr<TvgLottieAnimation> create()
    {
        return unique_ptr<TvgLottieAnimation>(new TvgLottieAnimation());
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

        canvas->clear(true);

        animation = Animation::gen();

        auto result = animation->picture()->load(data, sizeof(data), "lottie", false);

        if (result != Result::Success)
        {
            errorMsg = "load() fail";
            return false;
        }

        animation->picture()->size(&psize[0], &psize[1]);

        /* need to reset size to calculate scale in Picture.size internally before calling resize() */
        width = 0;
        height = 0;

        resize(width, height);

        if (canvas->push(cast(animation->picture())) != Result::Success)
        {
            errorMsg = "push() fail";
            return false;
        }

        updated = true;

        return true;
    }

    bool update()
    {
        if (!updated) return true;

        errorMsg = NoError;

        canvas->clear(false);

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

        if (canvas->draw() != Result::Success)
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
        canvas->target((uint32_t*)buffer, width, width, height, SwCanvas::ABGR8888S);

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
    explicit TvgLottieAnimation()
    {
        errorMsg = NoError;

        if (Initializer::init(CanvasEngine::Sw, 0) != Result::Success)
        {
            errorMsg = "init() fail";
            return;
        }

        canvas = SwCanvas::gen();
        if (!canvas) errorMsg = "Invalid canvas";

        animation = Animation::gen();
        if (!animation) errorMsg = "Invalid animation";
    }

private:
    const char* errorMsg;
    unique_ptr<SwCanvas> canvas = nullptr;
    unique_ptr<Animation> animation = nullptr;
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

    FlutterLottieAnimation* create()
    {
        return (FlutterLottieAnimation*)TvgLottieAnimation::create().release();
    }

    bool destroy(FlutterLottieAnimation* animation)
    {
        if (!animation) return false;
        delete (reinterpret_cast<TvgLottieAnimation*>(animation));
        return true;
    }

    bool load(FlutterLottieAnimation* animation, char* data, char* mimetype, int width, int height)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->load(data, mimetype, width, height);
    }

    bool update(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->update();
    }

    uint8_t* render(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->render();
    }

    float* size(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->size();
    }

    void resize(FlutterLottieAnimation* animation, int w, int h)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->resize(w, h);
    }

    float duration(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->duration();
    }

    float totalFrame(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->totalFrame();
    }

    float curFrame(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->curFrame();
    }

    bool frame(FlutterLottieAnimation* animation, float no)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->frame(no);
    }

    const char* error(FlutterLottieAnimation* animation)
    {
        return reinterpret_cast<TvgLottieAnimation*>(animation)->error();
    }

#ifdef __cplusplus
}
#endif
