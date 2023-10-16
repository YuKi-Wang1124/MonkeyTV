# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

install! 'cocoapods' , :warn_for_unused_master_specs_repo => false


target 'MonkeyTV' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for MonkeyTV
  pod 'Kingfisher', '~> 7.0'
  
  # Add the Firebase pod for Google Analytics
  pod 'FirebaseAnalytics'
  
  # For Analytics without IDFA collection capability, use this pod instead
  # pod ‘Firebase/AnalyticsWithoutAdIdSupport’
  
  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'SwiftLint'
  pod 'FirebaseFirestore'
  pod 'GoogleSignIn'
  pod 'FirebaseAuth'
  pod "youtube-ios-player-helper"
  pod 'IQKeyboardManagerSwift'
  pod 'FSPagerView'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'MJRefresh'
  pod 'NVActivityIndicatorView'
  pod 'lottie-ios'

  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
      end
    end
  end
end
