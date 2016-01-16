Pod::Spec.new do |s|
    s.name         = 'WBRefresh'
    s.version      = '1.0.1'
    s.summary      = 'An easy way to use refresh'
    s.homepage     = 'https://github.com/chatwyn/WBRefresh'
    s.license      = 'MIT'
    s.authors      = {'chatwyn' => 'chatwyn0217@gmail.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/chatwyn/WBRefresh.git', :tag => s.version}
    s.source_files = 'WBRefresh/*.swift'
    s.resource     = 'WBRefresh/WBRefresh.bundle'
    s.frameworks   = 'UIKit'
    s.module_name  = 'WBRefresh'
    s.requires_arc = true
end
