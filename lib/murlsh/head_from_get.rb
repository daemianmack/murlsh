module Murlsh

  # mixin for adding head() that calls get() and removed the body
  module HeadFromGet

    # call get() and remove the body
    def head(req)
      resp = get(req)
      resp.body = ''
      resp
    end

  end

end
