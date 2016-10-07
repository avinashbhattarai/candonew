# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'CanDo' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CanDo

pod 'IQKeyboardManagerSwift'
pod 'SVProgressHUD'
pod 'NVActivityIndicatorView'
pod 'Moya', '= 7.0.0'
pod 'Alamofire', '~> 3.4'
#pod 'ImagePicker'
pod 'Fabric'
pod 'Crashlytics'
pod 'PullToRefresher', '~> 1.4.0'
pod 'FSCalendar'
pod "ESPullToRefresh"
pod 'Kingfisher', '2.6'
pod "AFDateHelper", '3.4.2'


end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end