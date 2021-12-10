#
# Be sure to run `pod lib lint CBDNetworkEngine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CBDNetworkEngine'
  s.version          = '0.8.3'
  s.summary          = '巴士管家app中网络请求库CBDNetworkEngine.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
巴士管家app中网络请求库，叫做CBDNetworkEngine.
                       DESC

  s.homepage         = 'http://git.17usoft.com/wireless-bus/iOS_CBDNetworkEngine'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jiabibi888' => 'zjb11934@ly.com' }
  s.source           = { :git => 'git@git.17usoft.com:wireless-bus/iOS_CBDNetworkEngine.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CBDNetworkEngine/Classes/TCTNetworkEngine/**/*'
  # s.source_files = 'CBDNetworkEngine/Classes/TCTNetworkEngine/Public/*.h'

  # s.vendored_frameworks = "CBDNetworkEngine/Classes/FrameWork/CBDNetworkEngine.{framework}"

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', "DEFINES_MODULE" => "YES" }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  
  s.requires_arc = false
  s.requires_arc = ['Classes/TCTNetworkEngine/Public/*','Classes/TCTNetworkEngine/Private/*']

  s.frameworks = 'MobileCoreServices', 'CoreGraphics', 'SystemConfiguration', 'UIKit','Foundation', 'AdSupport'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'CBDConfig'
  
  # s.resource_bundles = {
  #   'CBDNetworkEngine' => ['CBDNetworkEngine/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.public_header_files = ['Pod/Classes/TCTNetworkEngine/Public/*.h','Pod/Classes/TCTNetworkEngine/Base64/*.h']
  # s.private_header_files = 'Pod/Classes/TCTNetworkEngine/Private/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
