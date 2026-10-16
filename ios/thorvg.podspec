#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thorvg.podspec` to validate before publishing.
#
require 'fileutils'

plugin_dir = File.expand_path('..', __dir__)
staging_dir = File.join(__dir__, '.cocoapods')
staged_paths = ['src', 'thorvg/inc', 'thorvg/src']

FileUtils.rm_rf(staging_dir)
staged_paths.each do |path|
  source_root = File.join(plugin_dir, path)
  raise "Missing ThorVG source directory: #{source_root}" unless File.directory?(source_root)

  Dir.glob('**/*', base: source_root).each do |relative_path|
    source = File.join(source_root, relative_path)
    next if File.directory?(source)

    destination = File.join(staging_dir, path, relative_path)
    FileUtils.mkdir_p(File.dirname(destination))
    File.symlink(source, destination)
  end
end

Pod::Spec.new do |s|
  s.name             = 'thorvg'
  s.version          = '0.0.1'
  s.summary          = 'ThorVG for Flutter'
  s.description      = <<-DESC
ThorVG Flutter Runtime
                      DESC
  s.homepage         = 'https://github.com/thorvg/thorvg.flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jinny You' => 'jinny@lottiefiles.com' }
  s.source           = { :path => '.' }

  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'
  s.static_framework = true

  s.script_phase = {
    :name => 'Generate ThorVG config.h',
    :execution_position => :before_compile,
    :output_files => ['${DERIVED_FILE_DIR}/config.h'],
    :script => <<~SCRIPT,
      set -eu
      mkdir -p "$(dirname "${SCRIPT_OUTPUT_FILE_0}")"
      cat > "${SCRIPT_OUTPUT_FILE_0}" <<'THORVG_CONFIG'
      #ifndef _THORVG_FLUTTER_IOS_CONFIG_H_
      #define _THORVG_FLUTTER_IOS_CONFIG_H_

      #define THORVG_VERSION_STRING "#{s.version}"
      #define THORVG_CPU_ENGINE_SUPPORT 1
      #define THORVG_PARTIAL_RENDER_SUPPORT 1
      #define THORVG_FILE_IO_SUPPORT 1
      #define THORVG_SVG_LOADER_SUPPORT 1
      #define THORVG_LOTTIE_LOADER_SUPPORT 1
      #define THORVG_LOTTIE_EXPRESSIONS_SUPPORT 1
      #define THORVG_PNG_LOADER_SUPPORT 1
      #define THORVG_JPG_LOADER_SUPPORT 1

      #endif
      THORVG_CONFIG
    SCRIPT
  }

  s.source_files = [
    '.cocoapods/src/tvgFlutterView.{cpp,h}',
    '.cocoapods/thorvg/src/common/*.cpp',
    '.cocoapods/thorvg/src/renderer/*.cpp',
    '.cocoapods/thorvg/src/renderer/cpu_engine/*.cpp',
    '.cocoapods/thorvg/src/loaders/lottie/tvgLottie*.cpp',
    '.cocoapods/thorvg/src/loaders/lottie/jerryscript/jerry-core/**/*.cpp',
    '.cocoapods/thorvg/src/loaders/svg/*.cpp',
    '.cocoapods/thorvg/src/loaders/png/*.cpp',
    '.cocoapods/thorvg/src/loaders/jpg/*.cpp',
    '.cocoapods/thorvg/src/loaders/raw/*.cpp',
  ]

  s.preserve_paths = '.cocoapods/**/*.h'
  s.public_header_files = '.cocoapods/src/tvgFlutterView.h'
  s.libraries = ['c++', 'z']

  jerry_core = 'src/loaders/lottie/jerryscript/jerry-core'
  thorvg_header_dirs = %W[
    inc
    src/common
    src/renderer
    src/renderer/cpu_engine
    src/loaders
    src/loaders/lottie
    src/loaders/svg
    src/loaders/png
    src/loaders/jpg
    src/loaders/raw
    #{jerry_core}/api
    #{jerry_core}/include
    #{jerry_core}/ecma/base
    #{jerry_core}/ecma/builtin-objects
    #{jerry_core}/ecma/builtin-objects/typedarray
    #{jerry_core}/ecma/operations
    #{jerry_core}/jcontext
    #{jerry_core}/jmem
    #{jerry_core}/jrt
    #{jerry_core}/lit
    #{jerry_core}/parser/js
    #{jerry_core}/parser/regexp
    #{jerry_core}/vm
  ]
  header_search_paths = ['${DERIVED_FILE_DIR}', '${PODS_TARGET_SRCROOT}/.cocoapods/src'] +
                        thorvg_header_dirs.map { |dir| "${PODS_TARGET_SRCROOT}/.cocoapods/thorvg/#{dir}" }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) TVG_STATIC=1',
    'GCC_SYMBOLS_PRIVATE_EXTERN' => 'NO',
    'HEADER_SEARCH_PATHS' => "$(inherited) #{header_search_paths.map { |path| "\"#{path}\"" }.join(' ')}",
    'OTHER_CPLUSPLUSFLAGS' => '$(inherited) -fno-exceptions -fno-rtti -fno-math-errno -Wno-unknown-pragmas -Wno-double-promotion -Wno-overloaded-virtual',
  }

  ffi_symbols = %w[create destroy error size duration totalFrame curFrame resize load render frame update]
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => "$(inherited) #{ffi_symbols.map { |symbol| "-Wl,-u,_#{symbol}" }.join(' ')}",
    'STRIP_STYLE' => 'non-global',
  }
end
