# Helper module to scrape Vieshow
module VieshowScrape
  VIESHOW_URL = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes'\
                '.aspx?visCinemaID=00'
  LANGUAGE_PARAM = '&visLang='
  LANGUAGES = %w(1, 2)
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

  def visit_vieshow(vis_cinema_id)
    # Include langauge settings in morning when film data is stable.
    # Add an extra parameter to this method
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
end
