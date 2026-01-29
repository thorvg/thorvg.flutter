project('thorvg-flutter',
        'cpp',
        default_options: ['cpp_std=c++14'])

cc = meson.get_compiler('cpp')


headers = include_directories('../thorvg/inc')
thorvg_lib_path = meson.project_source_root() + '/libthorvg.a'


source_file = [
    '../src/tvgFlutterLottieAnimation.cpp',
]

shared_library(
    'thorvg',
    source_file,
    include_directories : headers,
    link_args : [thorvg_lib_path]
)

library(
    'thorvg',
    source_file,
    include_directories : headers,
    link_args : [thorvg_lib_path]
)
