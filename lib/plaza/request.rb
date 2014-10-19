require 'faraday'
require 'faraday_middleware'
require_relative 'middleware/user_id'
require_relative 'middleware/exceptions'

module Plaza
  class Request
    attr_accessor :client, :connection
    attr_reader :logger

    def initialize(config_sym= :default)
      config = Plaza.configuration(config_sym)
      @connection = Faraday.new(config.base_url) do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/

        conn.use Plaza::Middleware::Exceptions
        conn.use Plaza::Middleware::UserId

        conn.headers[:accept] = 'application/json'
        yield(conn) if block_given?

        conn.adapter Faraday.default_adapter
      end
      @logger = config.logger
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
