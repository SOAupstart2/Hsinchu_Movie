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
  url = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes.aspx?visCinemaID=0005'
  open_doc = open(url,"Cookie" => "AspxAutoDetectCookieSupport=1")
  doc = Nokogiri::HTML(open_doc)
  TABLE = doc.xpath("//*[@class='PrintShowTimesTable']//td[@class='PrintShowTimesFilm' or @class='PrintShowTimesDay' or @class='PrintShowTimesSession']")
  MOVIE_TABLE   = {}
  
  # make movie_table like the structure {"name"=>[[day,time],[day,time],[day,time],[day,time]],"name2".....}
  def get_movie_table    
    current_movie = ''
    TABLE.each do |td|
      if    td.first[1] == "PrintShowTimesFilm"
        MOVIE_TABLE[td.text] = []
        current_movie        = td.text
      elsif td.first[1] == "PrintShowTimesDay"
        MOVIE_TABLE[current_movie] << [td.text]
      elsif td.first[1] == "PrintShowTimesSession"
        MOVIE_TABLE[current_movie][-1] << td.text 
      end  
    end
  end

  # get all movies' names
  def get_movie_name
    MOVIE_TABLE.keys
  end

  # get json format from movie_table
  def to_json
    get_movie_table
    MOVIE_TABLE.to_json
  end
  
end
