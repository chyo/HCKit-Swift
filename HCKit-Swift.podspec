
Pod::Spec.new do |s|

# 项目名
  s.name         = "HCKit-Swift"
# 版本号
  s.version      = "0.0.1"
# 摘要
  s.summary      = "A short description of HCKit-Swift."
# 描述
  s.description  = <<-DESC
                    描述
                   DESC
# 主页
  s.homepage     = "https://github.com/chyo/HCKit-Swift"
# 证书
  s.license      = "MIT"
# 作者
  s.author             = { "ChenHongchao" => "xmchc@hotmail.com" }
# 平台
  s.platform     = :ios, "8.0"
# 来源
  s.source       = { :git => "https://github.com/chyo/HCKit-Swift.git", :tag => "#{s.version}" }
# 源代码
  s.source_files  = "Classes/*.{h,m,swift}"
# 资源文件
  # s.resources = "Resources/*.png"
# 依赖系统库
  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
# ARC
  s.requires_arc = true
# XC配置
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
# 依赖库
  # s.dependency "JSONKit", "~> 1.4"

end
