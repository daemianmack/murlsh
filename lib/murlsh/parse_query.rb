require 'cgi'

module Murlsh

  # wrapper around CGI::parse that handles get or post and keeps only the
  # first occurrence for each name and stores values as strings instead of
  # lists
  def parse_query(req)
    input = case req.env['REQUEST_METHOD']
      when 'GET' then req.env['QUERY_STRING']
      when 'POST' then req.in.read
      else ''
    end
    result = {}
    CGI::parse(input).each_pair { |k,v| result[k] = v.first }
    result
  end

  module_function :parse_query

end
