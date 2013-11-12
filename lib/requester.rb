require 'json'

module Requester
  extend HTTParty

  def get(uri_string)
    response = HTTParty.get(uri_string, timeout: 5)
    if response.success?
      JSON.parse response.body
    else
      raise response.response
    end
  end

  def post(uri_string, params=[])
    response = HTTParty.post(uri_string, query: params)
    if response.code == 200
      JSON.parse response.body
    else
      response.error!
    end
  end
end