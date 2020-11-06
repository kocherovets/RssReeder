source 'https://github.com/CocoaPods/Specs.git'
workspace 'RssReeder'
use_frameworks!
platform :ios, ‘14.0’

target 'RssReeder' do
    project 'RssReeder'
    use_frameworks!
    inhibit_all_warnings!

    pod 'ReduxVM'
    pod 'DITranquillity'
    pod 'Kingfisher', '~> 5.0'
end

target 'RssReederTests' do
  project 'RssReeder'
  use_frameworks!
  inhibit_all_warnings!
end

target 'RssState' do
  pod 'RedSwift'
  pod 'ReduxVM'
  pod 'DITranquillity'
  pod 'FeedKit', '~> 9.0'
end

target 'RssStateTests' do
  project 'RssReeder'
  use_frameworks!
  inhibit_all_warnings!
end
