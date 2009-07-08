require 'murlsh'

module MurlshRequest

  def response_content_type
    @response_content_type ||=
      Murlsh.xhtml_content_type(env['HTTP_ACCEPT'], env['HTTP_USER_AGENT'])
  end

  def is_get?
    env['REQUEST_METHOD'] == 'GET'
  end

  def is_post?
    env['REQUEST_METHOD'] == 'POST'
  end

  def referrer
    env['HTTP_REFERER']
  end

  def query
    @query ||= Murlsh.parse_query(self)
  end

end
