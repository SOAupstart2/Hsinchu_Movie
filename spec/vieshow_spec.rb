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
  it 'should return films after a time' do
    TEST_SITES.each do |site|
      VCR.use_cassette("vieshow_table_#{site}") do
        cinema = HsinChuMovie::Vieshow.new(site.to_i)
        time = DateTime.now
        time_s = time.to_s[HOUR_MIN]
        after_films = cinema.films_after_time(time_s)
        exit if after_films.empty?
        comparison_time = (time - AN_HOUR).to_s[HOUR_MIN]
        after_films.each do |_film, date_times|
          # We're taking user input and getting results starting an hour back
          date_times.values.each do |show_times|
            show_times.each do |show_time|
              if (show_time < comparison_time) &&
                 (MIDNIGHT.include? show_time[0..1])
                # Movies airing from midnight onwards are group with past day
                show_time[0..1] = "#{show_time[0..1].to_i + 24}"
              end
              show_time.must_be :>=, comparison_time
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
