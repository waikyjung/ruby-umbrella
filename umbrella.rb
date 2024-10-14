require "http"
require "json"

class Coords
  attr_accessor :place, :latitude, :longitude, :google_http, :gmaps_key
  
  def initialize(place)
    @google_http = "https://maps.googleapis.com/maps/api/geocode/json?address="
    @gmaps_key = ENV.fetch("GMAPS_KEY")
    @place = place

    @request = @google_http + @place.gsub(" ", "%20") + "&key=" + @gmaps_key
    @raw_response = HTTP.get(@request)
    @parsed_response = JSON.parse(@raw_response)
    @geometry = @parsed_response.fetch("results")[0].fetch("geometry")
    
    @latitude = @geometry.fetch("location").fetch("lat")
    @longitude = @geometry.fetch("location").fetch("lng")
  end
end


coords1 = Coords.new("merchandise mart chicago")
