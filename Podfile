source 'https://github.com/CocoaPods/Specs.git'
workspace 'PubNubPoll.xcworkspace'
xcodeproj 'OSX/SimplePubNubPollHost.xcodeproj'

target 'SimplePubNubPollHost', :exclusive => true do
  platform :osx, '10.9'
  xcodeproj 'OSX/SimplePubNubPollHost.xcodeproj'
  pod 'PubNub'
end

target 'SimplePubNubPollAttendee', :exclusive => true do
  platform :ios, "8.0"
  xcodeproj 'iOS-watchOS/SimplePubNubPollAttendee.xcodeproj'
  pod 'PubNub'
end

target 'SimplePubNubPollAttendee Watch Extension', :exclusive => true do    
    platform :watchos, "2.0"
    xcodeproj 'iOS-watchOS/SimplePubNubPollAttendee.xcodeproj'
    pod 'PubNub'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'NO'
            config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = 'NO'
            if target.name == "CocoaLumberjack"
              config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
            end
        end
    end
end