require 'minitest/autorun'
require 'minitest/rg'
require 'json'
require 'vcr'
require 'webmock/minitest'
require 'yaml'
require './lib/kandianying'

MONTHS = Date::ABBR_MONTHNAMES.compact
DAYS = Date::ABBR_DAYNAMES
PARTIAL_NAME = 4..10
HOUR_MIN = 11..15
AN_HOUR = 1 / 24.to_f
MIDNIGHT = %w(00 01 02 03)
TAIWAN_TIME = '+8'
GIVEN_DAY = (0..2).to_a
A_TO_Z = 'A'..'Z'
MAX_ALPHABET = 26
HOUR_PART = 0..1
ADD_24 = 24
SEC_PART = 17..18
ZERO_SEC = '00'
LANGUAGE = %w(chinese english)

VCR.configure do |config|
  config.cassette_library_dir = './spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

def yml_load(file)
  YAML.load(File.read(file))
end
