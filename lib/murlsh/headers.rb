require 'cgi'

module Murlsh

  class Headers < Hash

    def content_type(content_type)
      self['Content-Type'] = content_type
      self
    end

    def cookie(params)
      self['Set-Cookie'] = fetch('Set-Cookie', []).push(
        CGI::Cookie::new(params).to_s)
      self
    end

    def status(status)
      self['Status'] = status
      self
    end

    def to_s
      sep = "\n"
      sort.collect { |k,v| [*v].collect { |v| "#{k}: #{v}" }.join(sep) }.join(sep)
    end

  end

end
