Pod::Spec.new do |s|

s.name = 'MI_SDK_DEVELOPMENT'

s.version = '1.0.0'

s.license = { :type => 'Unspecified' }

s.homepage = 'https://www.modirum.com'

s.authors = { 'Modirum Ou' => 'info@modirum.com' }

s.summary = 'Modirum 3DS SDK iOS framework (Development)'

s.platform = :ios

s.source = { :path => 'MI_SDK_DEVELOPMENT.framework.zip' }

s.ios.deployment_target = '8.0'

s.ios.vendored_frameworks = 'MI_SDK_DEVELOPMENT.framework'

end
