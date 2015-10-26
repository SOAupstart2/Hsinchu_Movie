require 'minitest/autorun'
require 'minitest/rg'
require 'json'
require 'vcr'
require 'webmock/minitest'

require './lib/kandianying'
require './spec/support/vcr_setup'

file_0005 = JSON.parse(File.read('./spec/fixtures/vieshow_0005.json'))
file_0012 = JSON.parse(File.read('./spec/fixtures/vieshow_0012.json'))

VCR.use_cassette('vieshow') do
  scrape_0005 = HsinChuMovie::Vieshow.new('0005').movie_table
  scrape_0012 = HsinChuMovie::Vieshow.new('0012').movie_table

  describe 'Check for difference between returned results and actual data and possibly HTML structure changes' do
    it 'have same number of movies' do
      file_0005.size.must_equal scrape_0005.size
      file_0012.size.must_equal scrape_0012.size
    end

    it 'must be same' do
      file_0005.must_equal scrape_0005
      file_0012.must_equal scrape_0012
    end  
  end
end