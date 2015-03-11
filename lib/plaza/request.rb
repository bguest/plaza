require 'faraday'
require 'faraday/http_cache'
require 'faraday_middleware'
require "faraday/conductivity"
require_relative 'middleware/user_id'
require_relative 'middleware/exceptions'

module Plaza
  class Request
    attr_accessor :client, :connection
    attr_reader :logger

    def initialize(config_sym= :default)
      @connection = Plaza.connection(config_sym)
      @logger = Plaza.configuration(config_sym).logger
    end

    def get(*args)
      Response.new(connection.get *args)
    end

    def post(*args)
      Response.new(connection.post *args)
    end

    def put(*args)
      Response.new(connection.put *args)
    end

    def delete(*args)
      Response.new(connection.delete *args)
    end

  end
end
