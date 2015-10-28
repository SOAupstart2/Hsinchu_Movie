require './spec/support/vcr_setup'

TEST_SITES = %w(05 12)
FAIL_SITES = %w(0 16)
FIXTURES = './spec/fixtures/vieshow_'

describe 'Get film information' do
  TEST_SITES.each do |site|
    it "must return same list of movies for #{site}" do
      VCR.use_cassette("vieshow_name_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        site_names = yml_load("#{FIXTURES}name_#{site}.yml")
        site_names.must_equal cinema.movie_names
      end
    end

    it "must return same table for #{site}" do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        site_table = yml_load("#{FIXTURES}table_#{site}.yml")
        site_table.must_equal cinema.movie_table
      end
    end
  end
end

describe 'Outside of 1 and 14 must fail' do
  FAIL_SITES.each do |site|
    it "must fail for #{site}" do
      # HsinChuMovie::Vieshow.new(site.to_i).must_fail
    end
  end
end
