#
# Be sure to run `pod lib lint Mew.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Mew'
  s.version          = '0.1.0'
  s.summary          = 'The framework that support making MicroViewController.'

  s.description      = <<-DESC
iOS MicroViewController support library.
                       DESC

  s.homepage         = 'https://github.com/mercari/Mew'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = ['Mercari, Inc.']
  s.source           = { :git => 'https://github.com/mercari/Mew.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/Mew/**/*.swift'
  
  s.resource_bundles = {
    'Mew' => ['Sources/Mew/ContainerView/_ContainerInterfaceBuilderView.xib']
  }

  s.frameworks = 'UIKit'
  
  s.cocoapods_version = '>= 1.4.0'
  s.swift_version = '4.0'
end
