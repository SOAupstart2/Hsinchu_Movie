require './spec/support/vcr_setup'

TEST_SITES = %w(05 12)
FAIL_SITES = %w(0 16)
INFO = %w(name table)
FIXTURES = './spec/fixtures/vieshow_'

describe 'Get film information' do
  TEST_SITES.each do |site|
    INFO.each do |t|
      LANGUAGE.each do |lang|
        it "must return same list of movies for #{site} & #{t} & #{lang}" do
          VCR.use_cassette("vieshow_#{t}_#{site}_#{lang}") do
            cinema = HsinChuMovie::Vieshow.new(site.to_i, lang)
            site_info = yml_load("#{FIXTURES}#{t}_#{site}_#{lang}.yml")
            compare = t == INFO[0] ? cinema.movie_names : cinema.movie_table
            site_info.must_equal compare
          end; end; end; end
  end
end

describe 'Get show times for a film' do
  TEST_SITES.each do |site|
    LANGUAGE.each do |lang|
      it 'should get viewing times for this film' do
        VCR.use_cassette("vieshow_table_#{site}_#{lang}") do
          cinema = HsinChuMovie::Vieshow.new(site.to_i, lang)
          one_movie = yml_load("#{FIXTURES}name_#{site}_#{lang}.yml")
                      .sample[PARTIAL_NAME]
          # Films are saved as UPPERCASE but search should pass any case
          cinema.film_times(one_movie.downcase).each do |film, date_times|
            film.must_include one_movie
            date_times.keys.each do |date|
              if lang == 'english'
                words_in_date = date.split
                MONTHS.must_include words_in_date.first
                DAYS.must_include words_in_date.last
              elsif lang == 'chinese'
                nums_in_date = date.split('/')
                MONTH_NUM.must_include nums_in_date.first
                DATE_NUM.must_include nums_in_date.last
              end
            end; end; end; end; end
  end
  TEST_SITES.each do |site|
    LANGUAGE.each do |lang|
      it 'should return empty array for random string' do
        VCR.use_cassette("vieshow_table_#{site}_#{lang}") do
          cinema = HsinChuMovie::Vieshow.new(site.to_i, lang)
          cinema.film_times(RANDOM_STRING).must_be_empty
        end; end; end
  end
end

describe 'Get films after a given time on given day' do
  TEST_SITES.each do |site|
    LANGUAGE.each do |lang|
      it "should only return films after a time for #{site}" do
        VCR.use_cassette("vieshow_table_#{site}_#{lang}") do
          cinema = HsinChuMovie::Vieshow.new(site.to_i, lang)
          time = DateTime.now.new_offset(TAIWAN_TIME)
          time += GIVEN_DAY.sample
          time_s = time.to_s
          time_s[SEC_PART] = ZERO_SEC
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
                     (MIDNIGHT.include? ast[HOUR_PART])
                    # Movies airing from midnight onwards are group w/ past day
                    ast[HOUR_PART] = "#{ast[HOUR_PART].to_i + ADD_24}"
                  end
                  ast.must_be :>=, comparison_time
                end
                show_times -= after_films[film][date]
                # Any show time not returned must be less than comparison time
                show_times.each do |show_time|
                  show_time.must_be :<, comparison_time
                end
              end; end; end; end; end; end
  end
end

describe 'Outside of 1 and 14 must fail' do
  FAIL_SITES.each do |site|
    LANGUAGE.each do |lang|
      it "must fail for #{site} for #{lang}" do
        proc { HsinChuMovie::Vieshow.new(site.to_i, lang) }
          .must_raise RuntimeError
      end; end; end
end

describe 'Not \'english\' or \'chinese\' must fail' do
  TEST_SITES.each do |site|
    it "must fail for #{site} for #{RANDOM_STRING}" do
      proc { HsinChuMovie::Vieshow.new(site.to_i, RANDOM_STRING) }
        .must_raise RuntimeError
    end; end
end
