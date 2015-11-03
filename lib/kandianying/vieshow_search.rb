# Helper module to search for films
module VieshowSearch
  NO_FILM = 'Film currently not on show'

  def find_film(film_name)
    film_name = film_name.downcase
    movie_names.select { |name| name if name.downcase.include? film_name }
  end

  def film_times(film_name)
    find_film(film_name).map { |film| { film => movie_table.values[0][film] } }
  end
end
