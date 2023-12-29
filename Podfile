# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Oklahoma' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod "FLUtilities", :git => 'https://github.com/Nickelfox/FLUtilities.git', :branch => 'master'
  pod "FLLogs", :git => 'https://github.com/Nickelfox/FLLogs.git', :branch => 'master'
  pod "AnyErrorKit", :git => 'https://github.com/Nickelfox/AnyErrorKit.git'
  pod 'Kingfisher'
  pod 'SwiftLint'
  pod 'ReactiveCocoa'
  pod 'ReactiveSwift'
  pod 'RealmSwift'
  pod 'FoxAPIKit', :git => 'https://github.com/Nickelfox/FoxAPIKit.git', :branch => 'master'
  pod 'MBProgressHUD'
  pod 'VimeoNetworking', :git => 'https://github.com/vimeo/VimeoNetworking'
  pod 'VersaPlayer'
  # Pods for Oklahoma

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end