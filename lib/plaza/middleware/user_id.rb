require 'faraday'

module Plaza
  module Middleware
    class UserId < Faraday::Middleware
      def call(env)
        env.request_headers[:x_user_id] = Thread.current[:x_user_id].to_s
        @app.call(env)
      end
    end
  end
end
