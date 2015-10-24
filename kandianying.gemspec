$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'kandianying/version'

Gem::Specification.new do |s|
  s.name        =  'kan_dian_ying'
  s.version     =  KanDianYing::VERSION
  s.date        =  KanDianYing::DATE
  s.executables << 'kandianying'
  s.summary     =  'Get movie information in Hsin Chu'
  s.description =  'Get movie information in Hsin Chu'
  s.authors     =  %w(stonegold546 huangjr pengyuchen stozuka)
  s.email       =  %w(stonegold546@gmail.com jr@nlplab.cc
                      pengyu@gmail.com stozuka@gmail.com)
  s.files       =  `git ls-files`.split("\n")
  # s.test_files  =  `git ls-files spec/*`.split("\n")
  s.homepage    =  'https://github.com/SOAupstart2/Hsinchu_Movie'
  s.license     =  'MIT'

  # s.add_development_dependency 'minitest'
  # s.add_development_dependency 'minitest-rg'
  # s.add_development_dependency 'vcr'
  # s.add_development_dependency 'webmock'
  s.add_runtime_dependency 'nokogiri'
end
