require "net/http"
require 'json'

module Requester
  def get(uri_string)
    uri = URI.parse(uri_string)
    response = nil
    Net::HTTP.start(uri.host, uri.port, timeout: 5) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
    end
    case response
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response['Location'])
      Net::HTTP.start(redirect_uri.host, redirect_uri.port, timeout: 5) do |http|
        request = Net::HTTP::Get.new redirect_uri
        response = http.request request
      end
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