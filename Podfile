# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end


target 'messenger' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

# Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'

# Facebook login
pod 'FBSDKLoginKit'

# Google
pod 'GoogleSignIn'

pod 'MessageKit'  
#pod 'InputBarAccessoryView'
pod 'JGProgressHUD'  
pod 'RealmSwift'  
pod 'SDWebImage'  

end
