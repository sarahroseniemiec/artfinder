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

    artist = api.artist(id: 'gustav-klimt')
    puts "#{artist.name} was born in #{artist.birthday} in #{artist.hometown} #{artist.artworks}"
    art = api.artworks(artist_id: artist.id)
    # @art = artist.artworks
    size = art._embedded.artworks[0].image_versions[0]
    puts size
    link = art._embedded.artworks[0]._links.image
    puts link.class

  end
end
