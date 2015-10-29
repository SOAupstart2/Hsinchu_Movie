require 'open-uri'
require 'nokogiri'
require 'json'
require 'yaml'

# Scraper for Ambassador
module Ambassador
  AMBASSADOR_THEATER_ID_URL = 'http://www.ambassador.com.tw/showtime_list.html'
  AMBASSADOR_THEATER_ID_XPATH = "//*[@class='list-group sidebar-nav-v1']//li//a"
  AMBASSADOR_TIME_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetScreeningDateListForTheater/?'
  AMBASSADOR_FILM_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetShowtimeListForTheater/?'
  # Class for Vieshow films
  class Ambassador
    attr_reader :movie_table
    attr_reader :theater_id_table
    def initialize
      @movie_table = {}
      @theater_id_table = fetch_theater_id_table(AMBASSADOR_THEATER_ID_URL)
      theater_id_table.each do |theater_id, theater_name|
        date_list = fetch_theater_date(theater_id)
        @movie_table[theater_name] = fetch_movie_info(theater_id, date_list)
      end
    end

    def fetch_movie_info(theater_id, date_list)
      movie_info = Hash.new { |h, k| h[k] = {} }
      date_list.each do |date|
        ur = "#{AMBASSADOR_FILM_API}theaterId=#{theater_id}&showingDate=#{date}"
        movies = JSON.parse(Nokogiri::HTML(open(ur)).text)
        movies.each do |movie|
          name = movie['ForeignName']
          time = movie['PeriodShowtime'].first['Showtimes']
          movie_info[name][date] = time
        end
      end
      movie_info
    end

    def fetch_theater_date(theater_id)
      url = "#{AMBASSADOR_TIME_API}theaterId=#{theater_id}"
      JSON.parse(Nokogiri::HTML(open(url)).text)
    end

    def fetch_theater_id_table(url)
      theater_id_list = {}
      open_doc = Nokogiri::HTML(open(url))
      theater = open_doc.xpath(AMBASSADOR_THEATER_ID_XPATH)
      theater.each do |t|
        theater_id = t.attributes['href'].value.split("'")[1]
        theater_name = t.text
        theater_id_list[theater_id] = theater_name
      end
      theater_id_list
    end

    def to_json
      @movie_table.to_json
    end

    def to_yaml
      @movie_table.to_yaml
    end
  end
end
