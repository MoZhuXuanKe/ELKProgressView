#
# Be sure to run `pod lib lint ELKProgressView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ELKProgressView'
  s.version          = '0.1.0'
  s.summary          = 'ELKProgressView 是一个简单易用的进度条视图'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'ELKProgressView 是一个简单易用的进度条视图,包含了横向进度条和环形进度条两种.具体用法见 demo'

  s.homepage         = 'https://github.com/MoZhuXuanKe/ELKProgressView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MoZhuXuanKe' => 'mozhuxuanke@icloud.com' }
  s.source           = { :git => 'https://github.com/MoZhuXuanKe/ELKProgressView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ELKProgressView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ELKProgressView' => ['ELKProgressView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
