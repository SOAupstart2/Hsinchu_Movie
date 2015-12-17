require 'open-uri'
require 'nokogiri'
require 'json'
require 'yaml'
require 'concurrent'
require_relative 'ambassador_scrape'
require_relative 'search'

# Scraper for Ambassador
module Ambassador
  INIT_ERR = 'id out of range'
  LANGUAGE_ERROR = 'language must be one of \'english\' or \'chinese\''
  LANGUAGES = %w(english chinese)

  # Class for Vieshow films
  class Ambassador
    include AmbassadorScrape, Search
    attr_reader :movie_table, :theater_id_table, :cinema_name

    def initialize(id, lang)
      @movie_table = {}
      @theater_id_table = fetch_theater_id_table(AMBASSADOR_THEATER_ID_URL)
      fail INIT_ERR unless theater_id_table.keys.any? { |key| key.include? id }
      fail LANGUAGE_ERROR unless LANGUAGES.include? lang
      theater_id_table.each do |theater_id, theater_name|
        next unless theater_id.include? id
        dates = fetch_theater_date(theater_id)
        @cinema_name = theater_name
        @movie_table[theater_name] = fetch_movie_info(theater_id, dates, lang)
      end
    end

    def movie_names
      @movie_table.values[0].keys
    end

    def to_json
      @movie_table.to_json
    end

    def to_yaml
      @movie_table.yaml
    end
  end
end
