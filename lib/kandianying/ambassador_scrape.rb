# Helper module to get data from Ambassador
module AmbassadorScrape
  AMBASSADOR_THEATER_ID_URL = 'http://www.ambassador.com.tw/showtime_list.html'
  AMBASSADOR_THEATER_ID_XPATH = "//*[@class='list-group sidebar-nav-v1']//li//a"
  AMBASSADOR_TIME_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetScreeningDateListForTheater/?'
  AMBASSADOR_FILM_API = 'http://cinemaservice.ambassador.com.tw/ambassadorsite.webapi/api/Movies/GetShowtimeListForTheater/?'

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
end