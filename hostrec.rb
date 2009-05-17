require 'uri'

module HostRec

  def HostRec.hostrec(url, title)
    host = URI.parse(url).host.sub(/^(www)\./, '')
    yield host if HostRec::necessary?(host, title)
  end

  WIDELY_KNOWN = [
    'en.wikipedia.org',
    'flickr.com',
    'github.com',
    'twitter.com',
    'vimeo.com',
    'youtube.com',
    ]

  def HostRec.necessary?(host, title)
    !(title.downcase.index(host.downcase) or WIDELY_KNOWN.include?(host))
  end

end
