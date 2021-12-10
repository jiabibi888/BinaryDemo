# MARK: converted automatically by spec.py. @hgy

Pod::Spec.new do |s|
	s.name = 'BinaryDemo'
	s.version = '1'
	s.description = '我只是一个测试的，主要是想要 s.dependency'
	s.license = 'MIT'
	s.summary = 'Seeyou'
	s.homepage = 'https://github.com/jiabibi888/BinaryDemo'
	s.authors = { 'jiabibi888' => 'zjb@chebada.com' }
	s.source = { :git => 'git@github.com:jiabibi888/BinaryDemo.git', :branch => 'dev' }
        s.requires_arc = true
        s.ios.deployment_target = '9.0'
        s.source_files = 'Source/**/*.{h,m,c}'
        s.public_header_files = 'Source/**/*.h'

        s.dependency 'CBDNetworkEngine'
        # s.dependency 'ZJBTableViewModel','0.1.0'
        # s.dependency 'FMDB'
        # s.dependency 'LKDBHelper'
        s.dependency 'CBDConfig'




end
