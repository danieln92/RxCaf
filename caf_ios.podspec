Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "CAF_iOS"
s.summary = "CAF_iOS is a common application framework written in Swift for internal using. All right reserved by Beesightsoft Co. Ltd"
s.requires_arc = true

# 2
s.version = "0.0.8"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Duy Nguyen" => "duy.nguyen@beesightsoft.com" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://bitbucket.org/beesightsoft/caf_ios.git"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://bitbucket.org/beesightsoft/caf_ios.git", :tag => "#{s.version}"}

# 7
s.framework = "Foundation"
s.dependency 'RxSwift', '~> 3.4.0'
s.dependency 'RxAlamofire', '~> 3.0.2'
s.dependency 'RxCocoa', '~> 3.4.0'
s.dependency 'RxSwiftUtilities', '~> 1.0.0'
s.dependency 'ObjectMapper', '~> 2.2.0'
s.dependency 'Kingfisher', '~> 3.5.0'
s.dependency 'Hero', '~> 0.3.0'
s.dependency 'NSObject+Rx', '~> 2.0.0'
s.dependency 'AlamofireActivityLogger', '~> 2.3.0'
s.dependency 'NVActivityIndicatorView', '~> 3.5.0'
s.dependency 'Toaster', '~> 2.0.0'
s.dependency 'Swinject', '~> 2.1.0'
s.dependency 'Validator', '~> 2.1.0'
s.dependency 'AFDateHelper', '~> 4.0.0'
s.dependency 'Toucan', '~> 0.6.0'
s.dependency 'Reachability', '~> 3.2.0'
s.dependency 'Then', '~> 2.1.0'

# 8
s.source_files = "caf_ios/**/*.{swift}"

# 9
# s.resources = "caf_ios/**/*.{png,jpeg,jpg,storyboard,xib}"

end