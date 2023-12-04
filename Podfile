# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'market' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for market
  
  # firebase
  pod 'FirebaseAuth'
  pod 'FirebaseMessaging'
  pod 'FirebaseFirestore'
  
  # restApi alamofire
  pod 'Alamofire', '5.1'
  
  # loading indicator
  pod 'NVActivityIndicatorView'
  
  # photo library
  pod 'BSImagePicker'

  # image slide
  pod 'ImageSlideshow/SDWebImage'
  
  # async image
  pod 'Nuke'
  
  # bottom sheet
  pod 'PanModal'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
      config.build_settings['CONFIGURATION_BUILD_DIR'] ='$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
