Pod::Spec.new do |s|
  s.name             = 'SmartProxy'
  s.version          = '0.0.4'
  s.summary          = 'A short description of SmartProxy.'

  s.description      =
  <<-DESC
  TODO: Add long description of the pod here.
  DESC

  s.homepage         = 'https://github.com/leo150/SmartProxy'
  s.license          = ''
  s.author           = { 'leo150' => 'sokolov.lev95@gmail.com' }
  s.source           = { :git => 'https://github.com/leo150/SmartProxy.git', :tag => s.version.to_s }

  s.source_files = 'SmartProxy/Classes/**/*'

  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'SwiftyJSON', '~> 3.0'

  s.ios.deployment_target = '9.2'
end
