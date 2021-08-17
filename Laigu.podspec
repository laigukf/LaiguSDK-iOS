# coding: utf-8
#
# Be sure to run `pod lib lint LaiguSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Laigu"
  s.version          = "3.7.0"
  s.summary          = "来鼓官方 SDK for iOS"
  s.description      = "来鼓官方的 iOS SDK"

  s.homepage         = "https://github.com/laigukf/LaiguSDK-iOS"
  s.license          = 'MIT'
  s.author           = { "laigu" => "laigukf@gmail.com" }
  s.source           = { :git => "https://github.com/laigukf/LaiguSDK-iOS.git", :tag => "v3.7.0" }
  s.social_media_url = "https://app.laigukf.com"
  s.documentation_url = "https://github.com/laigukf/LaiguSDK-iOS/wiki"
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec 'LaiguSDK' do |ss|
    ss.frameworks =  'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
    ss.vendored_frameworks = 'Laigu-SDK-files/LaiGuSDK.framework'
    ss.libraries  =  'sqlite3', 'icucore', 'stdc++'
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "${PODS_ROOT}/Laigu/Laigu-SDK-files"}
  end
  s.subspec 'LGChatViewController' do |ss|
    ss.dependency 'Laigu/LaiguSDK'
    # avoid compile error when using 'use frameworks!',because this header is c++, but in unbrellar header don't know how to compile, there's no '.mm' file in the context.
    ss.private_header_files = 'Laigu-SDK-files/LGChatViewController/Vendors/VoiceConvert/amrwapper/wav.h'
    ss.source_files = 'Laigu-SDK-files/LaiguSDKViewInterface/*.{h,m}', 'Laigu-SDK-files/LGChatViewController/**/*.{h,m,mm,cpp}', 'Laigu-SDK-files/LGMessageForm/**/*.{h,m}'
    ss.vendored_libraries = 'Laigu-SDK-files/LGChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a', 'Laigu-SDK-files/LGChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrwb.a'
    #ss.preserve_path = '**/libopencore-amrnb.a', '**/libopencore-amrwb.a'
    ss.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/Laigu/Laigu-SDK-files\"" }
    ss.resources = 'Laigu-SDK-files/LGChatViewController/Assets/LGChatViewAsset.bundle'
  end
  
  

end
