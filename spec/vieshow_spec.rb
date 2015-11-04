require './spec/support/vcr_setup'

TEST_SITES = %w(05 12)
FAIL_SITES = %w(0 16)
TEST_INFO = %w(name table)
FIXTURES = './spec/fixtures/vieshow_'
MONTHS = Date::ABBR_MONTHNAMES.compact
DAYS = Date::ABBR_DAYNAMES
PARTIAL_NAME = 4..10
HOUR_MIN = 11..15
AN_HOUR = 1 / 24.to_f
MIDNIGHT = %w(00 01 02 03)
TAIWAN_TIME = '+8'
GIVEN_DAY = (0..2).to_a

describe 'Get film information' do
  TEST_SITES.each do |site|
    TEST_INFO.each do |t|
      it "must return same list of movies for #{site}" do
        VCR.use_cassette("vieshow_#{t}_#{site}") do
          cinema = HsinChuMovie::Vieshow.new(site.to_i)
          site_info = yml_load("#{FIXTURES}#{t}_#{site}.yml")
          compare = t == TEST_INFO[0] ? cinema.movie_names : cinema.movie_table
          site_info.must_equal compare
        end; end; end
  end
end

describe 'Get show times for a film' do
  TEST_SITES.each do |site|
    it 'should get viewing times for this film' do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        one_movie = yml_load("#{FIXTURES}name_#{site}.yml").sample[PARTIAL_NAME]
        # Films are saved as UPPERCASE but search should pass any case
        cinema.film_times(one_movie.downcase).each do |film, date_times|
          film.must_include one_movie
          date_times.keys.each do |date|
            words_in_date = date.split
            MONTHS.must_include words_in_date.first
            DAYS.must_include words_in_date.last
          end; end; end
    end
  end
  TEST_SITES.each do |site|
    it 'should return empty array for random string' do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        one_movie = (PARTIAL_NAME).map { ('A'..'Z').to_a[rand(26)] }.join
        cinema.film_times(one_movie).must_be_empty
      end; end
  end
end

describe 'Get films after a given time on given day' do
  TEST_SITES.each do |site|
    it "should only return films after a time for #{site}" do
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        time = DateTime.now.new_offset(TAIWAN_TIME)
        time += GIVEN_DAY.sample
        time_s = time.to_s
        day_films = cinema.films_on_day(time_s)
        after_films = cinema.films_after_time(time_s)
        # comparison_time is an hour earlier than specified time
        comparison_time = (time - AN_HOUR).to_s[HOUR_MIN]
        day_films.each do |film, date_times|
          date_times.each do |date, show_times|
            if after_films[film].nil?
              # If empty, all show times must be less than comparison time
              show_times.each do |show_time|
                show_time.must_be :<, comparison_time
              end
            else
              after_show_times = after_films[film][date]
              after_show_times.each do |ast|
                # On day show times must include after request show times
                show_times.must_include ast
                # After show times must be greater than comparison time
                if (ast < comparison_time) &&
                   (MIDNIGHT.include? ast[0..1])
                  # Movies airing from midnight onwards are group with past day
                  ast[0..1] = "#{ast[0..1].to_i + 24}"
                end
                ast.must_be :>=, comparison_time
              end
              show_times -= after_films[film][date]
              # Any show time not returned must be less than comparison time
              show_times.each do |show_time|
                show_time.must_be :<, comparison_time
              end
            end; end; end; end; end
  end
end

describe 'Outside of 1 and 14 must fail' do
  FAIL_SITES.each do |site|
    it "must fail for #{site}" do
      proc { HsinChuMovie::Vieshow.new(site.to_i) }.must_raise RuntimeError
    end
  end
end
