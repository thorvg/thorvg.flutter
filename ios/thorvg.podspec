#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thorvg.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'thorvg'
  s.version          = '1.0.0-beta.0'
  s.summary          = 'ThorVG for Flutter'
  s.description      = <<-DESC
ThorVG Flutter Runtime
                      DESC
  s.homepage         = 'https://github.com/thorvg/thorvg.flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jinny You' => 'jinny@lottiefiles.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.libraries = ["c++", "z"]
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.vendored_libraries = 'Frameworks/libthorvg.dylib'

  s.swift_version = '5.0'
end
