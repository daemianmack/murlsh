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
    host = URI.parse(url).host.sub(/^(www)\./, '')
    yield host unless (title.downcase.index(host.downcase) or
      WIDELY_KNOWN.include?(host))
  end

end
