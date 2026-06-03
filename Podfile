# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

inhibit_all_warnings!

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
			xcconfig_path = config.base_configuration_reference.real_path
			xcconfig = File.read(xcconfig_path)
			xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
			File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
		end
	end
end

def shared_pods
	use_frameworks!
#	pod 'SVProgressHUD'
#	pod 'GoogleMaps'
#	pod 'GooglePlaces'
#	pod 'GCDWebServer'
#	pod 'FMDB'
#	pod 'Swifter', '~> 1.5.0'
end

target 'TourMe-Dev' do
	shared_pods
  # Pods for TourMe-Dev

end

target 'TourMe-Pro' do
	shared_pods
  # Pods for TourMe-Pro

end
