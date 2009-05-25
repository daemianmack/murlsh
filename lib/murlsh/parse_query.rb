require 'cgi'

module Murlsh

  # wrapper around CGI::parse that keep only the first occurrence for each
  # name and stores values as strings instead of lists
  def parse_query(s)
    result = {}
    CGI::parse(s).each_pair { |k,v| result[k] = v.first }
    result
  end

  module_function :parse_query

end
