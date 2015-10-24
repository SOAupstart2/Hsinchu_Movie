require 'open-uri'
require 'nokogiri'
require 'json'

# url   = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes.aspx?visCinemaID=0005'
# open_doc = open(url, ,"Cookie" => "AspxAutoDetectCookieSupport=1")
# table = doc.xpath("//*[@class='PrintShowTimesTable']//td[@class='PrintShowTimesFilm' or @class='PrintShowTimesDay' or @class='PrintShowTimesSession']")
# table[0].first[1]
#  {"name"=>[[day,time],[day,time],[day,time],[day,time]],"name2".....}


# Scraper for VieShow 
module VieShow
  
  #initialize movie_table with url  
  def initialize(visCinemaID)
    url = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes.aspx?visCinemaID=' + visCinemaID
    open_doc = open(url,"Cookie" => "AspxAutoDetectCookieSupport=1")
    doc = Nokogiri::HTML(open_doc)
    @table = doc.xpath("//*[@class='PrintShowTimesTable']//td[@class='PrintShowTimesFilm' or @class='PrintShowTimesDay' or @class='PrintShowTimesSession']")
    @movie_table   = {}
  end


  # make movie_table like the structure {"name"=>[[day,time],[day,time],[day,time],[day,time]],"name2".....}
  def get_movie_table    
    current_movie = ''
    @table.each do |td|
      if    td.first[1] == "PrintShowTimesFilm"
        @movie_table[td.text] = []
        current_movie        = td.text
      elsif td.first[1] == "PrintShowTimesDay"
        @movie_table[current_movie] << [td.text]
      elsif td.first[1] == "PrintShowTimesSession"
        @movie_table[current_movie][-1] << td.text 
      end  
    end
    @movie_table
  end

  # get all movies' names
  def get_movie_name
    get_movie_table
    @movie_table.keys
  end

  # get json format from movie_table
  def to_json
    get_movie_table
    @movie_table.to_json
  end
  
end
