require './spec/support/vcr_setup'

TEST_SITES = %w(05 12)
FAIL_SITES = %w(0 16)
TEST_INFO = %w(name table)
FIXTURES = './spec/fixtures/vieshow_'

describe 'Get film information' do
  TEST_SITES.each do |site|
    TEST_INFO.each do |t|
      it "must return same list of movies for #{site}" do
        VCR.use_cassette("vieshow_#{t}_#{site}") do
          cinema = HsinChuMovie::Vieshow.new(site.to_i)
          site_info = yml_load("#{FIXTURES}#{t}_#{site}.yml")
          compare = t == TEST_INFO[0] ? cinema.movie_names : cinema.movie_table
          site_info.must_equal compare
        end
      end
    end
  end
end

describe 'Get show times for a film' do
  # TODO: it 'should pass' do; use value from film list
  # TODO: it 'should fail' do; use random value of considerable length
end

describe 'Get films after a given time on given day' do
  # TODO: it 'should pass' do; generate random time;
  #       use DateTime to compare each returned time
  #       against hour earlier than stipulated.
end

describe 'Outside of 1 and 14 must fail' do
  # FAIL_SITES.each do |site|
  #   it "must fail for #{site}" do
  #     # HsinChuMovie::Vieshow.new(site.to_i).must_fail
  #   end
  # end
end
