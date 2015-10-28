require_relative './kandianying/vieshow'
require_relative './kandianying/ambassador'

# class for crawling movie information
class HsinChuMovie
  include VieShow
  include Ambassador
end
