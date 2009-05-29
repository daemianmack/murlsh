module Murlsh

  def xhtml_content_type(http_accept, http_user_agent)
    if http_accept.match(
      /((\*|application)\/\*|application\/xhtml\+xml)/i) and
      !http_user_agent.match(/ msie /i)
      'application/xhtml+xml'
    else
     'text/html'
    end
  end

  module_function :xhtml_content_type

end
