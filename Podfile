# Uncomment this line to define a global platform for your project
platform :osx, '10.9'

use_frameworks!
inhibit_all_warnings!

def objc()
    pod 'ObjectiveSugar'
    pod 'libextobjc'
end

target 'TVShows' do
    # Networking
	pod 'AFNetworking', '~> 2.6'
    pod 'AFNetworkActivityLogger', '~> 2.0'
    pod 'AFOnoResponseSerializer', '~> 1.0'
    
    # Logging
    pod 'CocoaLumberjack', '~> 2.2'
    
    # Core Data
    pod 'MagicalRecord', '~> 2.3', :subspecs => ['CocoaLumberjack', 'ShorthandMethodAliases']
    
    # Update
    #pod 'Sparkle'
    
    # Misc
    pod 'Ono', '~> 1.2'
    #pod 'LetsMove'
    #pod 'Operations'
end

target 'TVShowsTests' do
	#pod 'Specta', '~> 0.5'
	#pod 'Expecta', '~> 0.4'
end
