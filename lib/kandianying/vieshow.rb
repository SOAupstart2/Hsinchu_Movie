require 'open-uri'
require 'nokogiri'
require 'json'

# Scraper for VieShow
module VieShow
  # initialize movie_table with url
  def initialize(visCinemaID)
    url = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes.aspx?'\
          'visCinemaID=' + visCinemaID
    open_doc = open(url, 'Cookie' => 'AspxAutoDetectCookieSupport=1')
    doc = Nokogiri::HTML(open_doc)
    @table = doc.xpath("//*[@class='PrintShowTimesTable']//td"\
                       "[@class='PrintShowTimesFilm' "\
                       "or @class='PrintShowTimesDay' "\
                       "or @class='PrintShowTimesSession']")
    @movie_table = Hash.new { |hash, key| hash[key] = [] }
    make_movie_table
  end

  # make movie_table like the structure {"name"=>[[day,time],"name2".....}
  def make_movie_table
    current_movie = ''
    @table.each do |td|
      current_movie = movie_conditions(td, current_movie)
    end
    @movie_table.each {|k,v| movie_table[k]= v.to_h}
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
  def movie_name
    @movie_table.keys
  end

  # fetch movie_table
  def movie_table
    @movie_table
  end

  # get json format from movie_table
  def to_json
    @movie_table.to_json
  end
end
