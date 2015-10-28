require './spec/support/vcr_setup'

TEST_SITES = %w(38897fa9-094f-4e63-9d6d-c52408438cb6)
# FAIL_SITES = %w(0 16)
FIXTURES = './spec/fixtures/ambassador_'

describe 'Get film information' do
  TEST_SITES.each do |site|
    it "must return same list of movies for #{site}" do
      VCR.use_cassette("ambassador_name_#{site}") do
        cinema = HsinChuMovie::Ambassador.new
        name = cinema.theater_id_table[site]
        site_names = yml_load("#{FIXTURES}name_#{site}.yml")
        site_names.must_equal cinema.movie_table[name].keys
      end
    end

    it "must return same table for #{site}" do
      VCR.use_cassette("ambassador_table_#{site}") do
        cinema = HsinChuMovie::Ambassador.new
        name = cinema.theater_id_table[site]
        site_table = yml_load("#{FIXTURES}table_#{site}.yml")
        site_table.must_equal cinema.movie_table[name]
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
