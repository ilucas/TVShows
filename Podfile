# Uncomment this line to define a global platform for your project
platform :osx, '10.10'

use_frameworks!
inhibit_all_warnings!

def common
    # Networking
    pod 'AFNetworking', '~> 2.6'
    pod 'AFNetworkActivityLogger', '~> 2.0'
    pod 'AFOnoResponseSerializer', '~> 1.0'
    
    # Logging
    pod 'CocoaLumberjack', '~> 2.2'
    
    # Core Data
    pod 'MagicalRecord', '~> 2.3', :subspecs => ['CocoaLumberjack', 'ShorthandMethodAliases']
    
    # Model
    pod 'Mantle', '~> 2.0'
    pod 'MTLManagedObjectAdapter', '~> 1.0'
    
    # Misc
    pod 'Ono', '~> 1.2'
    
    # Objective-c stuff
    pod 'ObjectiveSugar'
    pod 'libextobjc'
end

target 'TVShows' do
    common
    
    # UI
    pod 'ITSwitch', '~> 1.0'
    
    # Update
    pod 'Sparkle'
    
    # Misc
    pod 'LetsMove'
end

target 'TVShowsHelper' do
    common
end
