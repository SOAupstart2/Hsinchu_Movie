require './spec/support/vcr_setup'

AMBASSADOR_TEST_SITES = %w(38897fa9-094f-4e63-9d6d-c52408438cb6
                           5c2d4697-7f54-4955-800c-7b3ad782582c)
# FAIL_SITES = %w(0 16)
AMBASSADOR_FIXTURES = './spec/fixtures/ambassador_'

describe 'Get film information' do
  AMBASSADOR_TEST_SITES.each do |site|
    it "must return same list of movies for #{site}" do
      VCR.use_cassette("ambassador_name_#{site}") do
        cinema = HsinChuMovie::Ambassador.new site
        site_names = yml_load("#{AMBASSADOR_FIXTURES}name_#{site}.yml")
        site_names.sort.must_equal cinema.movie_names.sort
      end
    end

    it "must return same table for #{site}" do
      VCR.use_cassette("ambassador_table_#{site}") do
        cinema = HsinChuMovie::Ambassador.new site
        site_table = yml_load("#{AMBASSADOR_FIXTURES}table_#{site}.yml")
        site_table.sort.to_h.must_equal cinema.movie_table.sort.to_h
      end
    end
  end
end

# describe 'Outside of 1 and 14 must fail' do
#   FAIL_SITES.each do |site|
#     it "must fail for #{site}" do
#       # HsinChuMovie::Vieshow.new(site.to_i).must_fail
#     end
#   end
# end
