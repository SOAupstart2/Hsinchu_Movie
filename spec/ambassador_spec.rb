require './spec/support/vcr_setup'

AMBASSADOR_TEST_SITES = %w(38897fa9-094f-4e63-9d6d-c52408438cb6
                           5c2d4697-7f54-4955-800c-7b3ad782582c)
# FAIL_SITES = %w(0 16)
AMB_FIXTURES = './spec/fixtures/ambassador_'

describe 'Get film information' do
  AMBASSADOR_TEST_SITES.each do |site|
    LANGUAGE.each do |lang|
      it "must return same list of movies for #{site} for #{lang}" do
        VCR.use_cassette("ambassador_name_#{site}_#{lang}") do
          cinema = HsinChuMovie::Ambassador.new(site, lang)
          site_names = yml_load("#{AMB_FIXTURES}name_#{site}_#{lang}.yml")
          site_names.must_equal cinema.movie_names
        end
      end

      it "must return same table for #{site} for #{lang}" do
        VCR.use_cassette("ambassador_table_#{site}_#{lang}") do
          cinema = HsinChuMovie::Ambassador.new(site, lang)
          site_table = yml_load("#{AMB_FIXTURES}table_#{site}_#{lang}.yml")
          site_table.must_equal cinema.movie_table
        end; end; end
  end
end

describe 'Get films after a given time on given day' do
  AMBASSADOR_TEST_SITES.each do |site|
    LANGUAGE.each do |lang|
      it "should only return films after a time for #{site} for #{lang}" do
        VCR.use_cassette("ambassador_table_#{site}_#{lang}") do
          cinema = HsinChuMovie::Ambassador.new(site, lang)
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
                    # Movies airing from midnight onwards are grouped w/past day
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

# describe 'Outside of 1 and 14 must fail' do
#   FAIL_SITES.each do |site|
#     it "must fail for #{site}" do
#       # HsinChuMovie::Vieshow.new(site.to_i).must_fail
#     end
#   end
# end
