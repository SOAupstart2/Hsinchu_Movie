# Helper module to search for films
module Search
  NO_FILM = 'Film currently not on show'
  AN_HOUR = 1 / 24.to_f
  TIMEZONE = '+8'
  MIDNIGHT = %w(00 01 02 03)

  def find_film(film_name)
    film_name = film_name.downcase
    movie_names.select { |name| name if name.downcase.include? film_name }
  end

  def film_times(film_name, temp_table = {})
    find_film(film_name).each do |film|
      temp_table[film] = movie_table.values[0][film]
    end
    temp_table
  end

  def films_on_day(datetime, temp_table = {})
    search_datetime = DateTime.parse("#{datetime}#{TIMEZONE}")
    movie_table.values[0].each do |name, date_time|
      date_time.each do |date, times|
        if DateTime.parse(date).to_date == search_datetime.to_date
          temp_table[name] = { date => times }
        end
      end
    end
    temp_table
  end

  def time_after(date, times, time_preferrence)
    times.select do |time|
      time if (MIDNIGHT.include? time[0..1]) ||
              (DateTime.parse("#{date} #{time}#{TIMEZONE}") >= time_preferrence)
    end
  end

  def films_after_time(datetime, temp_table = {})
    search_datetime = DateTime.parse("#{datetime}#{TIMEZONE}") - AN_HOUR
    films_on_day(datetime).each do |name, date_time|
      date_time.each do |date, times|
        time_array = time_after(date, times, search_datetime)
        temp_table[name] = { date => time_array } unless time_array.empty?
      end
    end
    temp_table
  end
end
