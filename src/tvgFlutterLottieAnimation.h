#include <stdint.h>
#include <stdbool.h>

typedef struct _FlutterLottieAnimation FlutterLottieAnimation;

#ifdef __cplusplus
extern "C"
{
#endif


FlutterLottieAnimation* create();
bool destroy(FlutterLottieAnimation* animation);
const char* error(FlutterLottieAnimation* animation);
float* size(FlutterLottieAnimation* animation);
float duration(FlutterLottieAnimation* animation);
float totalFrame(FlutterLottieAnimation* animation);
float curFrame(FlutterLottieAnimation* animation);
void resize(FlutterLottieAnimation* animation, int w, int h);
bool load(FlutterLottieAnimation* animation, char* data, char* mimetype, int width, int height);
uint8_t* render(FlutterLottieAnimation* animation);
bool frame(FlutterLottieAnimation* animation, float no);
bool update(FlutterLottieAnimation* animation);


#ifdef __cplusplus
}
#endif
