# Hsinchu_Movie[![Gem Version](https://badge.fury.io/rb/kandianying.svg)](https://badge.fury.io/rb/kandianying)[![Build Status](https://travis-ci.org/SOAupstart2/Hsinchu_Movie.svg)](https://travis-ci.org/SOAupstart2/Hsinchu_Movie)

https://rubygems.org/gems/kandianying

A simple Ruby Gem to get data from cinema websites in Hsinchu. Currently, we can get the film lists and show times given a vieshow cinema code.

## Installation

Run the following command:
```
gem install kandianying
```

### General usage notes
Currently, usage requires specifying a theater_id. This value ranges from 1 to 14. For a cinema located in Hsinchu, use 5 or 12.

### Command line usage
```
kandianying vieshow <theater_id>
# This prints out cinema name with films on display and show times.
```

### Usage in ruby code
```
require 'kandianying'

vieshow_movie = HsinChuMovie::Vieshow.new(<theater_id>)
vieshow_movie.movie_names  # Returns array of film names
vieshow_movie.movie_table  # Returns JSON array of film names, dates, time
vieshow_movie.to_json  # Puts JSON array of movie_table
```

## License
Distributed under the [MIT License](LICENSE).
