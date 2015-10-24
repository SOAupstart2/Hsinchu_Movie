require 'open-uri'
require 'nokogiri'
require 'json'

# Scraper for VieShow
module VieShow
  # initialize movie_table with url
  def initialize(visCinemaID)
    url = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes.aspx?visCinemaID=' + visCinemaID
    open_doc = open(url, 'Cookie' => 'AspxAutoDetectCookieSupport=1')
    doc = Nokogiri::HTML(open_doc)
    @table = doc.xpath("//*[@class='PrintShowTimesTable']//td[@class='PrintShowTimesFilm' "\
                       "or @class='PrintShowTimesDay' "\
                       "or @class='PrintShowTimesSession']")
    @movie_table = {}
    make_movie_table
  end

  # make movie_table like the structure {"name"=>[[day,time],"name2".....}
  def make_movie_table
    current_movie = ''
    @table.each do |td|
      case td.first[1]
      when 'PrintShowTimesFilm'
        @movie_table[td.text] = []
        current_movie = td.text
      when 'PrintShowTimesDay'
        @movie_table[current_movie] << [td.text]
      when 'PrintShowTimesSession'
        @movie_table[current_movie][-1] << td.text
      end
    end
  end

  # get all movies' names
  def make_movie_name
    @movie_table.keys
  end

  # get json format from movie_table
  def to_json
    @movie_table.to_json
  end
end
