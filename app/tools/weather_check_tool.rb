# frozen_string_literal: true

class WeatherCheckTool < MCP::Tool
  description "TODO: Add description for WeatherCheckTool"

  input_schema(
    properties: {
      location: { type: "string" },
      date: { type: "string" }
    },
    required: []
  )


  def self.call(location: nil, date: nil, server_context:)
    # Check if weather API is configured
    if ENV["WEATHER_API_KEY"].blank? || ENV["WEATHER_FORECAST_URL"].blank? || ENV["WEATHER_COORDINATES_URL"].blank?
      return MCP::Tool::Response.new([
        {
          type: "text",
          text: "Weather API is not configured. Please set WEATHER_API_KEY, WEATHER_FORECAST_URL, and WEATHER_COORDINATES_URL environment variables."
        }
      ])
    end

    # Parse date if not provided or if it's a relative date like "tomorrow"
    parsed_date = parse_date(date)

    # Get weather forecast
    forecast_data = Weather::Forecast.call(location:, date: parsed_date)

    # Format the response
    if forecast_data.is_a?(Hash) && forecast_data["list"]
      # OpenWeatherMap format
      weather_info = forecast_data["list"].first
      if weather_info
        temp_kelvin = weather_info.dig("main", "temp")
        temp_celsius = temp_kelvin ? (temp_kelvin - 273.15).round(1) : "N/A"
        description = weather_info.dig("weather", 0, "description")
        humidity = weather_info.dig("main", "humidity")
        wind_speed_ms = weather_info.dig("wind", "speed")
        wind_speed_kph = wind_speed_ms ? (wind_speed_ms * 3.6).round(1) : "N/A"

        response_text = "Weather forecast for #{location}:\n"
        response_text += "Temperature: #{temp_celsius}°C\n"
        response_text += "Description: #{description}\n"
        response_text += "Humidity: #{humidity}%\n"
        response_text += "Wind Speed: #{wind_speed_kph} km/h"
      else
        response_text = "No weather data available for #{location}"
      end
    else
      response_text = "Weather data received but in unexpected format: #{forecast_data.inspect}"
    end

    MCP::Tool::Response.new([ { type: "text", text: response_text } ])
  rescue StandardError => e
    MCP::Tool::Response.new([ { type: "text", text: "An error occurred while fetching weather data: #{e.message}" } ])
  end

  private

  def self.parse_date(date_input)
    return nil if date_input.blank?

    case date_input.downcase.strip
    when "today"
      Date.current
    when "tomorrow"
      Date.current + 1.day
    when "yesterday"
      Date.current - 1.day
    else
      # Try to parse as a date string
      begin
        Date.parse(date_input)
      rescue ArgumentError
        # If parsing fails, return the original input
        date_input
      end
    end
  end
end
