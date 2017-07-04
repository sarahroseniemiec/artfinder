class HomeController < ApplicationController
require 'net/http'
require 'json'
require 'hyperclient'



  def index
    client_id = ENV['ARTSY_CLIENT_ID']
    client_secret = ENV['ARTSY_CLIENT_SECRET']
    api_url = URI.parse('https://api.artsy.net/api/tokens/xapp_token')
    response = Net::HTTP.post_form(api_url, client_id: client_id, client_secret: client_secret)
    xapp_token = JSON.parse(response.body)['token']
    api = Hyperclient.new('https://api.artsy.net/api') do |api|
      api.headers['Accept'] = 'application/vnd.artsy-v2+json'
      api.headers['X-Xapp-Token'] = xapp_token
      api.connection(default: false) do |conn|
        conn.use FaradayMiddleware::FollowRedirects
        conn.use Faraday::Response::RaiseError
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter :net_http
      end
    end

    andy_warhol = api.artist(id: 'andy-warhol')
    puts "#{andy_warhol.name} was born in #{andy_warhol.birthday} in #{andy_warhol.hometown} #{andy_warhol.artworks}"

    puts "yoooo"


  end
end
