platform :ios, '15.0'

target 'QuoteNGo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.0'
  pod 'AlamofireImage'
  pod 'SwiftyJSON'

  target 'QuoteNGoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QuoteNGoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
               end
          end
   end
end