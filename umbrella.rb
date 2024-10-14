require "active_support/all"
require "http"
require "json"
require "date"
require "ascii_charts"

=begin
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
=end

class Weather
  attr_accessor :google_http, :weather_http
  
  def get_coords(place)
    @google_http = "https://maps.googleapis.com/maps/api/geocode/json?address="
    @gmaps_key = ENV.fetch("GMAPS_KEY")
    @place = place

    @google_request = @google_http + @place.gsub(" ", "%20") + "&key=" + @gmaps_key
    @google_raw_response = HTTP.get(@google_request)
    @google_response = JSON.parse(@google_raw_response)
    @geometry = @google_response.fetch("results")[0].fetch("geometry")
    
    @latitude = @geometry.fetch("location").fetch("lat")
    @longitude = @geometry.fetch("location").fetch("lng")
    return [@latitude, @longitude]
  end

  def get_temps(coords)
    @weather_http = "https://api.pirateweather.net/forecast/"
    @weather_key = ENV.fetch("PIRATE_WEATHER_API_KEY")
    @latitude = coords[0]
    @longitude = coords[1]

    @weather_request = @weather_http + @weather_key + "/" + @latitude.to_s + "," + @longitude.to_s
    @weather_raw_response = HTTP.get(@weather_request)
    @weather_response = JSON.parse(@weather_raw_response)

    @current_time = @weather_response.fetch("currently").fetch("time")
    @current_time = DateTime.strptime(@current_time.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I:%M%p")
    @current_temp = @weather_response.fetch("currently").fetch("temperature")
    
    @data = @weather_response.fetch("hourly").fetch("data")
    @temps = @data[0..11]
  end

  def precip_description(precip_intensity)
    case precip_intensity
    when 0
      return ""
    when 0.001..0.097
      return "Light Rain"
    when 0.098..0.299
      return "Moderate Rain"
    else
      return "Heavy Rain"
    end
  end

  def display_forecast
    for i in 0..11
      @time = @temps[i].fetch("time")
      @time = DateTime.strptime(@time.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I%p")
      @time = @time[1..-1] if @time[0] == "0"
      @summary = @temps[i].fetch("summary")
      @temperature = @temps[i].fetch("temperature")
      @precip_intensity = @temps[i].fetch("precipIntensity")
      @precip_description = self.precip_description(@precip_intensity)
      @precip_per = @temps[i].fetch("precipProbability") * 100
      @precip_per = @precip_per.round(0).to_i
      puts "#{@time} - #{@summary} - #{@temperature}°F - #{@precip_per}% #{@precip_description}".strip
    end
  end

  def display_forecast_chart
    @plots = []
    for i in 0..11
      @time = @temps[i].fetch("time")
      @time = DateTime.strptime(@time.to_s, "%s").in_time_zone("Central Time (US & Canada)").strftime("%I%p")
      @time = @time[1..-1] if @time[0] == "0"
      @precip_per = @temps[i].fetch("precipProbability") * 100
      @precip_per = @precip_per.round(0)
      @plots.push([@time, @precip_per])
    end
    puts AsciiCharts::Cartesian.new(@plots, :bar => true, :hide_zero => true).draw
  end

  
  def start
    @border = "="*40
    puts @border
    puts "    Will you need an umbrella today?"
    puts @border
    puts
    puts "Where are you?"
    @location = gets.chomp.split.map(&:capitalize).join(" ")
    
    puts "Checking the weather at #{@location}"
    @coords = get_coords(@location)
    @temps = get_temps(@coords)
    
    puts "Your coordinates are #{@coords[0]}, #{@coords[1]}"
    puts "It is currently #{@current_temp}°F"
    @precip_per_next = @temps[1].fetch("precipProbability") * 100
    @precip_per_next = @precip_per_next.round(0)
    @precip_intensity_next = @temps[1].fetch("precipIntensity")
    @precip_description = self.precip_description(@precip_intensity_next)
    pp @precip_per_next
    pp @precip_description
    #self.display_forecast
  end
end

new_weather = Weather.new
new_weather.start
