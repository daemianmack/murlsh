require 'cgi'

module Murlsh

  HttpStatus = {
    :ok => '200 OK',
    :forbidden => '403 Forbidden',
    :error => '500 Internal Server Error',
  }

  ContentType = {
    :json => 'application/json',
    :text => 'text/plain',
  }

  class Headers < Hash


    def content_type(content_type)
      self['Content-Type'] = ContentType[content_type] || content_type
      self
    end

    def cookie(params)
      self['Set-Cookie'] = fetch('Set-Cookie', []).push(
        CGI::Cookie::new(params).to_s)
      self
    end

    def status(status)
      self['Status'] = HttpStatus[status] || status
      self
    end

    def to_s
      sep = "\n"
      sort.collect { |k,v| [*v].collect { |v| "#{k}: #{v}" }.join(sep) }.join(sep)
    end

  end

end
