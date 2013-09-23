require "net/http"
require 'json'

module Requester
  def get(uri_string)
    uri = URI.parse(uri_string)
    response = Net::HTTP.get_response(uri)
    
    case response
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response['Location'])
      response = Net::HTTP.get_response(redirect_uri)
      JSON.parse response.body
    when Net::HTTPSuccess
      JSON.parse response.body
    else
      response.error!
    end
  end

  def post(uri_string, params=[])
    uri = URI(uri_string)
    http = Net::HTTP.new(uri.host, uri.port)
    response = Net::HTTP.post_form(uri, params)
    if response.is_a? Net::HTTPOK
      JSON.parse response.body
    else
      response.error!
    end
  end
end