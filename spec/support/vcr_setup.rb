require 'minitest/autorun'
require 'minitest/rg'
require 'json'
require 'vcr'
require 'webmock/minitest'
require 'yaml'
require './lib/kandianying'

VCR.configure do |config|
  config.cassette_library_dir = './spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

def yml_load(file)
  YAML.load(File.read(file))
end
