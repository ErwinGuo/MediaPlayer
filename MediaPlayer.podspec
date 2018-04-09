#
#  Be sure to run `pod spec lint MediaPlayer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "MediaPlayer"

  s.version      = "0.0.1"

  s.summary      = "A iOS mediaplayer of MediaPlayer."

  s.license      = "MIT"

  s.platform     = :ios,'9.0'

  s.source       = { :git => "https://github.com/cirelir/MediaPlayer.git", :tag=>"0.0.1" }
  
  s.description  = "这是一个iOS 媒体播放器, A iOS mediaplayer of MediaPlayer"
  
  s.homepage     = "https://github.com/cirelir/MediaPlayer.git"
  
  s.author       = { "cirelir" => "1193436556@qq.com" }
  
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  
  s.exclude_files = "Classes/Exclude"

end
