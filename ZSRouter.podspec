#
# Be sure to run `pod lib lint ZSRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSRouter'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZSRouter.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Zss1990'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.author           = { '_coCo_' => 'https://github.com/Zss1990' }
  s.source           = { :git => 'https://github.com/Zss1990/ZSRouter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.ios.deployment_target = '9.0'

  # 1. Dynamic 动态库、2. Static  静态库、3. Library 三方库封装，如HPR，OpenSSL
  library_type       = "Dynamic"
  # s.static_framework = true

# ------------------ 组件资源---------------------
  s.source_files = 'ZSRouter/Classes/**/*.{h,m}'
  s.public_header_files  = 'ZSRouter/Classes/**/*.h'
  s.ios.resource = [
    'ZSRouter/Assets/**/*.{png,xib,storyboard,bundle,xcassets,xml}',
    'ZSRouter/Classes/**/*.{png,xib,storyboard,xml}'
  ]
  s.ios.frameworks = 'UIKit','Foundation'




    # ------------------ 组件依赖---------------------

  


     #------------------ 组件info配置 --------------------------
 s.pod_target_xcconfig  = {
     'FRAMEWORK_SEARCH_PATHS'        => '$(inherited) ${PODS_ROOT}/**',
     'LIBRARY_SEARCH_PATHS'          => '$(inherited) ${PODS_ROOT}/**',
     'ENABLE_BITCODE'                => 'NO',
     'OTHER_LDFLAGS'                 => '$(inherited) -ObjC',
     'STRINGS_FILE_OUTPUT_ENCODING'  => 'UTF-8',
     'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
 }
end
