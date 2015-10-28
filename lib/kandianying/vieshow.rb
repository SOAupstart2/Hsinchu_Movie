require 'open-uri'
require 'nokogiri'
require 'json'

# Scraper for VieShow
module VieShow
  VIESHOW_URL = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes'\
                '.aspx?visCinemaID=00'
  VIESHOW_COOKIE_SETTINGS = 'AspxAutoDetectCookieSupport=1'
  VIESHOW_BASE_XPATH = 'PrintShowTimes'
  VIESHOW_CLASSES_XPATH = %w(Film Day Session)
  VIESHOW_TABLE_XPATH = "//*[@class=\'#{VIESHOW_BASE_XPATH}Table\']//td"
  VIESHOW_DATA_XPATH = VIESHOW_CLASSES_XPATH.map do |scrape_class|
    "@class=\'#{VIESHOW_BASE_XPATH}#{scrape_class}\'"
  end.join(' or ')
  VIESHOW_FULL_XPATH = VIESHOW_TABLE_XPATH + '[' + VIESHOW_DATA_XPATH + ']'
  VIESHOW_CINEMA_CODES = ('1'..'14').to_a.map do |e|
    e.length == 1 ? "0#{e}" : e
  end
  VIESHOW_CINEMA_NAME_XPATH = "//*[contains(@class, 'PrintCinemaName')]"

  # Class for Vieshow films
  class Vieshow
    # initialize movie_table with ID
    def initialize(vis_cinema_id)
      vis_cinema_id = vis_cinema_id.to_s
      vis_cinema_id = "0#{vis_cinema_id}" if vis_cinema_id.length == 1
      fail unless VIESHOW_CINEMA_CODES.include? vis_cinema_id
      doc = visit_vieshow(vis_cinema_id)
      @table = doc.xpath(VIESHOW_FULL_XPATH)
      @cinema_name = doc.xpath(VIESHOW_CINEMA_NAME_XPATH).text
      @movie_table = Hash.new { |hash, key| hash[key] = [] }
      make_movie_table
      @movie_table = { @cinema_name => @movie_table }
    end

    # fetch movie_table
    attr_reader :movie_table, :cinema_name

    def visit_vieshow(vis_cinema_id)
      url = VIESHOW_URL + vis_cinema_id
      open_doc = open(url, 'Cookie' => VIESHOW_COOKIE_SETTINGS)
      Nokogiri::HTML(open_doc)
    end

    # make movie_table like the structure {"name"=>[[day,time],"name2".....}
    def make_movie_table
      current_movie = ''
      @table.each do |td|
        current_movie = movie_conditions(td, current_movie)
      end
      @movie_table.each { |k, v| movie_table[k] = v.to_h }
    end

    # make make_movie_table simple
    def movie_conditions(td, current_movie)
      case td.first[1]
      when 'PrintShowTimesFilm'
        current_movie = td.text
      when 'PrintShowTimesDay'
        @movie_table[current_movie] << [td.text]
      when 'PrintShowTimesSession'
        @movie_table[current_movie][-1] << td.text
      end
      current_movie
    end

    # get all movies' names
    def movie_names
      @movie_table.values[0].keys
    end

    # get json format from movie_table
    def to_json
      @movie_table.to_json
    end
  end
end
