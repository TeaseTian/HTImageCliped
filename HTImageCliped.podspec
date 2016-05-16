

Pod::Spec.new do |s|


  s.name         = "HTImageCliped"
  s.version      = "1.0.0"
  s.summary      = "kinds of clipped for UIButton UIImage UIImageView UIView"
  s.description  = <<-DESC
		支持多重空间圆角切换
                   DESC

  s.homepage     = "https://github.com/TeaseTian/HTImageCliped"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "TeaseTian" => "330972860@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/TeaseTian/HTImageCliped.git", :tag => s.version }
  s.source_files  ="HTImageCliped/*.{h,m}"
  s.public_header_files = "HTImageCliped.h"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
