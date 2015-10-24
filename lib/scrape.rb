require_relative './vieshow'

# Scraper class for several sites
class SiteScraper
  include VieShow

  def movie_table_output
    puts to_json
  end
end
