# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ComicReader' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ComicReader
  pod 'PluggableAppDelegate'
  pod 'Swinject'
  pod 'Bond'
  pod 'ReactiveKit'
  pod 'SDWebImage', '~> 5.0'

  target 'ComicReaderTests' do
    inherit! :search_paths
    pod 'Swinject'
    pod 'OHHTTPStubs/Swift'
  end

  target 'ComicReaderUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
