require 'uri'

module HostRec

  WIDELY_KNOWN = [
    'en.wikipedia.org',
    'flickr.com',
    'github.com',
    'twitter.com',
    'vimeo.com',
    'youtube.com',
    ]

  def hostrec
    begin
      host = URI.parse(url).host.sub(/^(www)\./, '')
    rescue Exception => e
      host = nil
    end
    yield host unless !host or (title.downcase.index(host.downcase) or
      WIDELY_KNOWN.include?(host))
  end

end
