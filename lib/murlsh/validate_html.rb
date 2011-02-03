require 'cgi'

module Murlsh

  module_function

  # Validate a document with the W3C validation service.
  def validate_html(check_url, options={})
    opts = {
      :validator_host => 'validator.w3.org',
      :validator_port => 80,
      :validator_path =>
        "/check?uri=#{CGI.escape(check_url)}&charset=(detect+automatically)&doctype=Inline&group=0",
    }.merge options

    net_http = Net::HTTP.new(opts[:validator_host], opts[:validator_port])
    net_http.set_debug_output(opts[:debug])  if opts[:debug]

    net_http.start do |http|
      resp = http.request_head(opts[:validator_path])
      result = { :response => resp }
      if Net::HTTPSuccess === resp
        result.merge!(
          :status =>  resp['X-W3C-Validator-Status'],
          :errors => resp['X-W3C-Validator-Errors'],
          :warnings => resp['X-W3C-Validator-Warnings']
        )
      end
      result
    end

  end

end
