Pod::Spec.new do |s|
  s.name             = 'DeviceConnectExilimPlugin'
  s.version          = '0.4.0'
  s.license          = { :type => 'MIT' }
  s.summary          = 'DeviceConnect device plugin for CASIO EXILIM.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod is DeviceConnect device plugin for CASIO EXILIM digital cameras.
                       DESC

  s.homepage         = 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS'
  s.author           = 'CASIO COMPUTER Co., LTD.'
  s.source           = { :git => 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.vendored_frameworks = 'DeviceConnectExilimPlugin.framework'
  s.public_header_files = 'DeviceConnectExilimPlugin.framework/Headers/*.h'

  s.dependency 'RxSwift', '~> 4.1.2'
  s.dependency 'RxCocoa', '~> 4.0'
  s.dependency 'RxAutomaton'
  s.dependency 'DeviceConnectSDK', '= 2.1.3'
  s.dependency 'CocoaAsyncSocket', '= 7.6.1'
  s.dependency 'ReachabilitySwift', '= 4.1.0'
end
