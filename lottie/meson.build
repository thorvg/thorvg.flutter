project('thorvg-flutter',
        'cpp',
        default_options: ['cpp_std=c++14'])

cc = meson.get_compiler('cpp')


thorvg_lib = cc.find_library('thorvg', dirs: meson.current_source_dir())
headers = include_directories('../thorvg/inc')


source_file = [
   '../src/tvgFlutterLottieAnimation.cpp',
]

thorvg_lib_dep = declare_dependency(dependencies: thorvg_lib, include_directories: headers)

shared_library(
    'thorvg',
    [ '../src/tvgFlutterLottieAnimation.cpp' ],
    include_directories : headers,

    dependencies : [thorvg_lib_dep]
)

library(
    'thorvg',
    [ '../src/tvgFlutterLottieAnimation.cpp' ],
    include_directories : headers,

    dependencies : [thorvg_lib_dep]
)
