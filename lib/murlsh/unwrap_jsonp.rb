%w{
json
}.each { |m| require m }

module Murlsh

  module_function

  # Unwrap jsonp to standard json and parse it.
  def unwrap_jsonp(jsonp)
    json = /.+?\((.+)\)/m.match(jsonp)[1]
    JSON.parse(json)
  end

end
