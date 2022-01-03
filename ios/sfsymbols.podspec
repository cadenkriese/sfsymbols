#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ios_platform_images.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sfsymbols'
  s.version          = '0.0.1'
  s.summary          = 'Flutter SF Symbols'
  s.description      = <<-DESC
A Flutter plugin to load SF Symbols from iOS.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/sfsymbols' }
  s.documentation_url = 'https://pub.dev/packages/sfsymbols'
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
