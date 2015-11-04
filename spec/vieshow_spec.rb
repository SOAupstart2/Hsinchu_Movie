require './spec/support/vcr_setup'

TEST_SITES = %w(05 12)
FAIL_SITES = %w(0 16)
TEST_INFO = %w(name table)
FIXTURES = './spec/fixtures/vieshow_'
MONTHS = Date::MONTHNAMES.map { |month| month[0..2] unless month.nil? }.compact
DAYS = Date::DAYNAMES.map { |day| day[0..2] }
PARTIAL_NAME = 4..10

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
  TEST_SITES.each do |site|
    it 'should get viewing times for this film' do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        one_movie = yml_load("#{FIXTURES}name_#{site}.yml").sample[PARTIAL_NAME]
        # Films are saved as UPPERCASE but search should pass any case
        cinema.film_times(one_movie.downcase).each do |film|
          film.keys[0].must_include one_movie
          film.values.each do |date_times|
            date_times.keys.each do |date|
              words_in_date = date.split
              MONTHS.must_include words_in_date.first
              DAYS.must_include words_in_date.last
            end; end; end; end; end
  end
  TEST_SITES.each do |site|
    it 'should return empty array for random string' do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        one_movie = (PARTIAL_NAME).map { ('A'..'Z').to_a[rand(26)] }.join
        cinema.film_times(one_movie).must_be_empty
      end; end; end
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
