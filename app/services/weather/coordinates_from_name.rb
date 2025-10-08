# frozen_string_literal: true

class Weather::CoordinatesFromName
  WEATHER_API_KEY = ENV["WEATHER_API_KEY"]
  BASE_URL=ENV["WEATHER_COORDINATES_URL"]

  def self.call(name:)
    new(name:).call
  end

  def initialize(name:)
    @connection = Faraday.new(url: BASE_URL) do |config|
      config.params = { q: "#{name}, PT", limit: 1, appid: WEATHER_API_KEY }
      config.headers = { "Content-Type" => "application/json" }
      config.response :json
    end
    @name = name
  end

  attr_reader :connection

  def call
    connection.get.body
  end
end
