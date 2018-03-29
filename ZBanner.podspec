Pod::Spec.new do |s|
  s.name             = 'ZBanner'
  s.version          = '1.0.4'
  s.summary          = 'a simple scorll banner view'
 
  s.description      = <<-DESC
仿网易云音乐轮播图 适配iPhone 和 ipad版本
                       DESC
 
  s.homepage         = 'https://github.com/zhangshuqing/ZBanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangshuqing' => 'zhangshuqing912@163.com' }
  s.source           = { :git => 'https://github.com/zhangshuqing/ZBanner.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'Banner/ZBanner/*'
  swift_version = '3.2'
 
end