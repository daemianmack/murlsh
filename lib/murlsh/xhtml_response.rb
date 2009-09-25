module Murlsh

  class XhtmlResponse < Rack::Response

    # set the content type to application/xhtml+xml for anything that
    # claims to accept it, for anything else or IE use text/html
    def set_content_type(http_accept, http_user_agent)
      self['Content-Type'] = if http_accept and
        http_accept[/((\*|application)\/\*|application\/xhtml\+xml)/i] and
        (!http_user_agent or !http_user_agent[/ msie /i])
        'application/xhtml+xml'
      else
       'text/html'
      end
    end

  end

end
