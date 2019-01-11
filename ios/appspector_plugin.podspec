#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'appspector_plugin'
  s.version          = '0.0.1'
  s.summary          = 'AppSpector SDK'
  s.description      = <<-DESC
AppSpector SDK
                       DESC
  s.homepage         = 'https://appspector.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'info@appspector.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AppSpectorSDK'

  s.ios.deployment_target = '8.0'
end

