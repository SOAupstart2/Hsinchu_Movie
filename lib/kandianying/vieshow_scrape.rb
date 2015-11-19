# Helper module to scrape Vieshow
module VieshowScrape
  VIESHOW_URL = 'http://sales.vscinemas.com.tw/ticketing/visPrintShowTimes'\
                '.aspx?visCinemaID=00'
  LANGUAGE_PARAM = '&visLang='
  PICK_LANGUAGE = { 'english' => '1', 'chinese' => '2' }
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

  def visit_vieshow(vis_cinema_id, language)
    url = VIESHOW_URL + vis_cinema_id + LANGUAGE_PARAM + PICK_LANGUAGE[language]
    open_doc = open(url, 'Cookie' => VIESHOW_COOKIE_SETTINGS).read
    Nokogiri::HTML(open_doc)
  end

  # make movie_table like the structure {"name"=>[[day,time],"name2".....}
  def make_movie_table(langauge)
    @movie_table = Hash.new { |hash, key| hash[key] = [] }
    current_movie = ''
    @table.each do |td|
      current_movie = movie_conditions(td, current_movie, langauge)
    end
    @movie_table.each { |k, v| movie_table[k] = v.to_h }
  end

  def make_chinese_dates_english(text, langauge)
    return [text] unless langauge == 'chinese'
    text = text.split.map { |x| x[/\d+/] }.compact if langauge == 'chinese'
    [text.join('/')]
  end

  def initiatilize_table_cinema_name(doc)
    [doc.xpath(VIESHOW_FULL_XPATH), doc.xpath(VIESHOW_CINEMA_NAME_XPATH).text]
  end

  # make make_movie_table simple
  def movie_conditions(td, current_movie, langauge)
    case td.first[1]
    when 'PrintShowTimesFilm'
      current_movie = td.text
    when 'PrintShowTimesDay'
      date_in_array = make_chinese_dates_english(td.text, langauge)
      @movie_table[current_movie] << date_in_array
    when 'PrintShowTimesSession'
      @movie_table[current_movie][-1] << td.text.split(', ')
    end
    current_movie
  end
end
