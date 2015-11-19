# Helper module to get data from Ambassador
module AmbassadorScrape
  AMBASSADOR_THEATER_ID_URL = 'http://www.ambassador.com.tw/showtime_list.html'
  AMBASSADOR_THEATER_ID_XPATH = "//*[@class='list-group sidebar-nav-v1']//li//a"
  AMBASSADOR_TIME_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetScreeningDateListForTheater/?'
  AMBASSADOR_FILM_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetShowtimeListForTheater/?'
  PICK_LANGUAGE = { 'chinese' => 'Name', 'english' => 'ForeignName' }
  PERIOD_SHOW_TIME = 'PeriodShowtime'
  SHOW_TIMES = 'Showtimes'

  def fetch_movie_info(theater_id, date_list, language)
    language = PICK_LANGUAGE[language]
    movie_info = Hash.new { |hash, key| hash[key] = {} }
    date_list.map do |date|
      url = "#{AMBASSADOR_FILM_API}theaterId=#{theater_id}&showingDate=#{date}"
      JSON.parse(open(url).read).map do |movie|
        name, time = *name_time(movie, language)
        movie_info[name][date] = time
      end; end # .map(&:execute).map(&:value)
    movie_info # .sort.to_h
  end

  def name_time(movie, language)
    movie = movie
    [movie[language], movie[PERIOD_SHOW_TIME].first[SHOW_TIMES]]
  end

  # def concurrent_retrieve_info(url, date, movie_info)
  #   Concurrent::Future.new do
  #     JSON.parse(Nokogiri::HTML(open(url)).text).map do |movie|
  #       name = movie['ForeignName']
  #       time = movie['PeriodShowtime'].first['Showtimes']
  #       movie_info[name][date] = time
  #     end
  #   end
  # end

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
end
