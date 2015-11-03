require 'open-uri'
require 'nokogiri'
require 'json'
require_relative './vieshow_scrape'

# Scraper for VieShow
module VieShow
  INITIALIZE_ERROR = 'id out of range'

  # Class for Vieshow films
  class Vieshow
    include VieshowScrape
    # initialize movie_table with ID
    def initialize(vis_cinema_id)
      vis_cinema_id = vis_cinema_id.to_s
      vis_cinema_id = "0#{vis_cinema_id}" if vis_cinema_id.length == 1
      fail INITIALIZE_ERROR unless VIESHOW_CINEMA_CODES.include? vis_cinema_id
      doc = visit_vieshow(vis_cinema_id)
      @table = doc.xpath(VIESHOW_FULL_XPATH)
      @cinema_name = doc.xpath(VIESHOW_CINEMA_NAME_XPATH).text
      @movie_table = Hash.new { |hash, key| hash[key] = [] }
      make_movie_table
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
