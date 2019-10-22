# Uncomment the next line to define a global platform for your project
#platform :ios, '8.0'

def shared_pods
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    inhibit_all_warnings!
    use_frameworks!
    
    # Pods for SalonWalker
    pod 'Alamofire'
    pod 'Kingfisher'
    pod 'SwiftMessages'
    pod 'JTAppleCalendar'
    pod 'FBSDKLoginKit'
    pod 'GoogleSignIn'
    pod 'GoogleMaps'
    pod 'SQLite.swift'
    pod 'IQKeyboardManagerSwift'
    pod 'SwiftSVG'
    pod 'Branch'
    pod 'Firebase/Core'
    pod 'Fabric'
    pod 'Crashlytics'

    pod 'LLCycleScrollView'
    pod 'Cosmos'
    pod 'DKImagePickerController', :git => 'https://github.com/zhangao0086/DKImagePickerController.git', :branch => 'develop', :subspecs => ['PhotoGallery', 'Camera', 'InlineCamera']
    pod 'FlexiblePageControl', :git => 'https://github.com/shima11/FlexiblePageControl.git'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
        
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
                if config.name == 'Debug'
                    config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
                    else
                    config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
                end
            end
        end
    end
end

target 'SalonWalker_UAT' do
    shared_pods
    
end

target 'SalonWalker_DEV' do
    shared_pods
    
end

target 'SalonWalker_AppStore' do
    shared_pods
    
end

target 'SalonMaker_UAT' do
    shared_pods
    
end

target 'SalonMaker_DEV' do
    shared_pods
    
end

target 'SalonMaker_AppStore' do
    shared_pods
    
end
