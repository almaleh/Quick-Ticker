#
# Be sure to run `pod lib lint QuickTicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QuickTicker'
  s.version          = '0.1.0'
  s.summary          = 'A Swift library for animating labels and text fields'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A simple library to animate labels and textfields using similar syntax to UIView's animate methhods.
  
  It works even if there is text mixed in with numbers in the same label. Text remains intact while the digits get animated!
                       DESC

  s.homepage         = 'https://github.com/almaleh/Quick-Ticker'
  s.screenshots      = 'https://github.com/almaleh/Quick-Ticker/blob/master/Images/screenshot.png'#, 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BesherAlMaleh' => 'almalehdev@gmail.com' }
  s.source           = { :git => 'https://github.com/AlMaleh/Quick-Ticker.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BesherMaleh'

  s.ios.deployment_target = '8.0'

  s.source_files = 'QuickTicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'QuickTicker' => ['QuickTicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'UIKit'#, 'CoreAnimation'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.swift_version = '4.2'
end
