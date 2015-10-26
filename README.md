# Hsinchu_Movie[![Gem Version](https://badge.fury.io/rb/kandianying.svg)](https://badge.fury.io/rb/kandianying)

https://rubygems.org/gems/kandianying

A simple Ruby Gem to scrap the website vieshow and to get film list and its dates and time.


## Usage

Run the following command:

```
gem install kandianying
```
### Command line usage

```
kandianying theater id
```

Puts information of films to command line,
- vieshow
  - 0005 is for VS Cinemas Hsinchu FE21  
  - 0012 is for Vie Show Cinemas Hsinchu Big City

### Usage in ruby code
```
require 'kandianying'

vieshow_movie = HsinChuMovie::Vieshow.new('0005')
vieshow_movie.movie_names  # Returns array of film names
vieshow_movie.movie_table  # Returns JSON array of film names, dates, time
vieshow_movie.to_json  # Puts JSON array of movie_table
```

## License

Distributed under the [MIT License](LICENSE).
