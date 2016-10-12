# Uncomment this line to define a global platform for your project
#platform :ios, '10.0'

target 'CanDo' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CanDo

pod 'IQKeyboardManagerSwift', '4.0.6'
pod 'SVProgressHUD'
pod 'NVActivityIndicatorView', '3.0'
pod 'Moya', '8.0.0-beta.2'
pod 'Alamofire', '~> 4.0'
#pod 'ImagePicker'
pod 'Fabric'
pod 'Crashlytics'
#pod 'PullToRefresher'
pod 'FSCalendar'
pod "ESPullToRefresh", '2.1'
pod 'Kingfisher', '~> 3.0'
#pod "AFDateHelper", '3.4.2'


end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
