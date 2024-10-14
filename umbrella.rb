require "active_support/all"
require "http"
require "json"
require "date"
require "ascii_charts"

class Coords
  attr_accessor :place, :latitude, :longitude, :google_http
  
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
  attr_accessor :place, :latitude, :longitude, :weather_http
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
    @temps = @data[0..11]
  end

  def display
    for i in 0..11
      @time = @temps[i].fetch("time")
      @time = DateTime.strptime(@time.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I%p")
      @time = @time[1..-1] if @time[0] == "0"
      @summary = @temps[i].fetch("summary")
      @temperature = @temps[i].fetch("temperature")
      @percip_per = @temps[i].fetch("precipProbability") * 100
      @percip_per = @percip_per.round(0)
      pp "#{@time} - #{@summary} - #{@temperature} degrees - #{@percip_per}% Percipitation"
    end
  end

  def chart
    @plots = []
    for i in 0..11
      @time = @temps[i].fetch("time")
      @time = DateTime.strptime(@time.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I%p")
      @time = @time[1..-1] if @time[0] == "0"
      @percip_per = @temps[i].fetch("precipProbability") * 100
      @percip_per = @percip_per.round(0)
      @plots.push([@time, @percip_per])
    end
    puts AsciiCharts::Cartesian.new(@plots, :bar => true, :hide_zero => true).draw
  end
end

coords1 = Coords.new("merchandise mart chicago")
weather1 = Weather.new(coords1.place, coords1.latitude, coords1.longitude)
weather1.chart
