require 'open-uri'
require 'nokogiri'
require 'json'
require_relative './vieshow_scrape'
require_relative './search'

# Scraper for VieShow
module VieShow
  INITIALIZE_ERROR = 'id out of range'
  LANGUAGE_ERROR = 'language must be one of \'english\' or \'chinese\''

  # Class for Vieshow films
  class Vieshow
    include VieshowScrape, Search
    # initialize movie_table with ID
    def initialize(vis_cinema_id, langauge)
      vis_cinema_id = vis_cinema_id.to_s
      vis_cinema_id = "0#{vis_cinema_id}" if vis_cinema_id.length == 1
      fail INITIALIZE_ERROR unless VIESHOW_CINEMA_CODES.include? vis_cinema_id
      fail LANGUAGE_ERROR unless PICK_LANGUAGE.keys.include? langauge
      doc = visit_vieshow(vis_cinema_id, langauge)
      @table, @cinema_name = initiatilize_table_cinema_name(doc)
      make_movie_table(langauge)
      @movie_table = { @cinema_name => @movie_table }
    end

    # fetch movie_table
    attr_reader :movie_table, :cinema_name

    # get all movies' names
    def movie_names
      @movie_table.values[0].keys
    end

    # get json format from movie_table
    def to_json
      @movie_table.to_json
    end
  end
end
