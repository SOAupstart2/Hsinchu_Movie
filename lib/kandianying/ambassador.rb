require 'open-uri'
require 'nokogiri'
require 'json'
require 'yaml'
require_relative 'ambassador_scrape'

# Scraper for Ambassador
module Ambassador
  # Class for Vieshow films
  class Ambassador
    include AmbassadorScrape
    attr_reader :movie_table, :theater_id_table
    def initialize
      @movie_table = {}
      @theater_id_table = fetch_theater_id_table(AMBASSADOR_THEATER_ID_URL)
      theater_id_table.each do |theater_id, theater_name|
        date_list = fetch_theater_date(theater_id)
        @movie_table[theater_name] = fetch_movie_info(theater_id, date_list)
      end
    end

    def to_json
      @movie_table.to_json
    end

    def to_yaml
      @movie_table.yaml
    end
  end
end
