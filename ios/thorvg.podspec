#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thorvg.podspec` to validate before publishing.
#
require 'fileutils'

plugin_dir = File.expand_path('..', __dir__)
staging_dir = File.join(__dir__, '.cocoapods')
staged_paths = ['src', 'thorvg/inc', 'thorvg/src']

FileUtils.rm_rf(staging_dir)
staged_paths.each do |path|
  source_root = File.join(plugin_dir, path)
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
  s.static_framework = true

  thorvg_source_globs = %w[
    common/*.cpp
    renderer/*.cpp
    renderer/cpu_engine/*.cpp
    loaders/lottie/*.cpp
    loaders/lottie/jerryscript/jerry-core/**/*.cpp
    loaders/svg/*.cpp
    loaders/png/*.cpp
    loaders/jpg/*.cpp
    loaders/raw/*.cpp
  ]
  s.source_files = ['.cocoapods/src/tvgFlutterView.cpp'] +
                   thorvg_source_globs.map { |glob| ".cocoapods/thorvg/src/#{glob}" }

  jerry_core = 'src/loaders/lottie/jerryscript/jerry-core'
  thorvg_header_dirs = %W[
    inc
    src/common
    src/renderer
    src/renderer/cpu_engine
    src/loaders/lottie
    src/loaders/svg
    src/loaders/png
    src/loaders/jpg
    src/loaders/raw
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
  header_search_paths = ['${PODS_TARGET_SRCROOT}'] +
                        thorvg_header_dirs.map { |dir| "${PODS_TARGET_SRCROOT}/.cocoapods/thorvg/#{dir}" }

  # Flutter.framework does not contain a i386 slice.
  s.libraries = ["c++", "z"]
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) TVG_STATIC=1',
    'HEADER_SEARCH_PATHS' => "$(inherited) #{header_search_paths.map { |path| "\"#{path}\"" }.join(' ')}",
    'OTHER_CPLUSPLUSFLAGS' => '$(inherited) -fno-exceptions -fno-rtti -fno-math-errno -Wno-unknown-pragmas',
  }

  ffi_symbols = %w[create destroy error size duration totalFrame curFrame resize load render frame update]
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => "$(inherited) #{ffi_symbols.map { |symbol| "-Wl,-u,_#{symbol}" }.join(' ')}",
    'STRIP_STYLE' => 'non-global',
  }

  s.swift_version = '5.0'
end
