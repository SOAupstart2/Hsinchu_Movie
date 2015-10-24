require_relative './kandianying/vieshow'

# class for crawling movie information
class HsinChuMovie
  include VieShow

  def movie_table_output
    to_json
  end
end
