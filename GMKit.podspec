#
# Be sure to run `pod lib lint GMDKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GMKit'
  s.version          = '0.1.0'
  s.summary          = 'A set of helper tools that will make iOS development easier.'

  s.description      = 'A set of helper tools that will make iOS development easier.'
  s.homepage         = 'https://github.com/gabemdev/GMDKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gabe Morales' => 'gabomorales@me.com' }
  s.source           = { :git => 'https://github.com/gabemdev/GMDKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.frameworks = 'UIKit', 'MapKit'
  s.source_files = 'GMDKit/**/*.{swift}'

end
