require "active_support/all"
require "http"
require "json"
require "date"

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

class Weather
  attr_accessor :place, :latitude, :longitude, :weather_http, :weather_key
  attr_reader :temps, :request
  def initialize(place, latitude, longitude)
    @weather_http = "https://api.pirateweather.net/forecast/"
    @weather_key = ENV.fetch("PIRATE_WEATHER_API_KEY")
    @place = place
    @latitude = latitude
    @longitude = longitude

    @request = @weather_http + @weather_key + "/" + @latitude.to_s + "," + @longitude.to_s
    @raw_response = HTTP.get(@request)
    @parsed_response = JSON.parse(@raw_response)
    @data = @parsed_response.fetch("hourly").fetch("data")
    @temps = []
    for i in 0..11
      @temps.push(@data[i])
    end
  end
end

coords1 = Coords.new("merchandise mart chicago")
weather1 = Weather.new(coords1.place, coords1.latitude, coords1.longitude)

for i in 0..11
  time1 = weather1.temps[i].fetch("time")
  time2 = DateTime.strptime(time1.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I:%M:%S %p")
  summary = weather1.temps[i].fetch("summary")
  temperature = weather1.temps[i].fetch("temperature")
  precipProbability = weather1.temps[i].fetch("precipProbability") * 100
  precipProbability = precipProbability.round(0)
  pp "#{time2} - #{summary} - #{temperature} degrees - #{precipProbability}% Percipitation"
end
