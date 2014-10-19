require 'plaza/models/error'

module Plaza::Middleware
  class Exceptions < Faraday::Middleware
    def call(env)
      begin
        @app.call(env)
      rescue Faraday::Error::ConnectionFailed => e
        error = Plaza::ConnectionError.new(nil, 'Service is not available.')
        raise(error, error.to_s)
      end
    end
  end
end
