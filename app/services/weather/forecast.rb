# frozen_string_literal: true

class Weather::Forecast
  WEATHER_API_KEY = ENV["WEATHER_API_KEY"]
  BASE_URL=ENV["WEATHER_FORECAST_URL"]

  def self.call(...)
    new(...).call
  end

  attr_reader :connection

  def initialize(location:, date:)
    Weather::CoordinatesFromName.call(name: location).first.symbolize_keys => { lat:, lon: }
    @connection = Faraday.new(url: BASE_URL) do |config|
      config.params = { lat:, lon:, appid: WEATHER_API_KEY }
      config.headers = { "Content-Type" => "application/json" }
      config.response :json
    end
  end

  def call
    connection.get.body
  end
end
