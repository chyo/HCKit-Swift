Pod::Spec.new do |s|

# 项目名
s.name         = "HCKit-Swift"
# 版本号
s.version      = "0.0.19"
# 摘要
s.summary      = "一个简单的Swift库"
# 描述
s.description  = <<-DESC
一个森罗万象的Swift库
DESC
# 主页
s.homepage     = "https://github.com/chyo/HCKit-Swift"
# 证书
s.license      = "MIT"
# 作者
s.author             = { "ChenHongchao" => "xmchc@hotmail.com" }
# 平台
s.platform     = :ios, "8.2"
# Swift版本
s.swift_version = "4.0"
# 来源
s.source       = { :git => "https://github.com/chyo/HCKit-Swift.git", :tag => "#{s.version}" }
# 源代码
s.source_files  = "Classes/**/*.swift", "Module/*.modulemap"
# 资源文件
s.resources = "Resources/*"
# 依赖系统库
# s.framework  = "SomeFramework"
# s.frameworks = "SomeFramework", "AnotherFramework"
# s.library   = "apple_crypto"
# s.libraries = "iconv", "xml2"
# ARC
s.requires_arc = true
# XC配置
s.preserve_path = "Module/module.modulemap"
# s.module_map = "Module/module.modulemap"
s.xcconfig = { "SWIFT_INCLUDE_PATHS" => "$(PODS_ROOT)/HCKit-Swift/Module"}
# 依赖库
s.dependency "SnapKit", "~> 4.0.0"
s.dependency "Kingfisher", "~> 4.8.0"

end
