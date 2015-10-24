# Hsinchu_Movie

https://rubygems.org/gems/kan_dian_ying

A simple Ruby Gem to scrap the website vieshow and to get film list and its dates and time.


## Usage

Run the following command:

```
gem install kandianying
```
### Command line usage

```
kandianying 0005  # Puts JSON array of vieshow's films to command line
```

### Usage in ruby code
```
require 'soa_codeschool'

code_school = SiteScraper.new
code_school.course_names  # Returns array of course names
code_school.code_school_data  # Returns JSON array of code school courses and teachers
code_school.code_school_output  # Puts JSON array of code school courses and teachers
```

## License

Distributed under the [MIT License](LICENSE).