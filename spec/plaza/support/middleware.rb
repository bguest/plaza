module Example
  class HelloMiddleware < Faraday::Middleware
    def call(request_env)
      request_env.request_headers['Greetings'] ||= ""
      request_env.request_headers['Greetings'] << 'Hello'
      @app.call(request_env).on_complete do |response_env|
        response_env.response_headers['Greetings'] ||= ""
        response_env.response_headers['Greetings'] << 'Hello'
      end
    end
  end

  class GoodbyeMiddleware < Faraday::Middleware
    def call(request_env)
      request_env.request_headers['Greetings'] ||= ""
      request_env.request_headers['Greetings'] << 'Goodbye'
      @app.call(request_env).on_complete do |response_env|
        response_env.response_headers['Greetings'] ||= ""
        response_env.response_headers['Greetings'] << 'Goodbye'
      end
    end
  end
end

