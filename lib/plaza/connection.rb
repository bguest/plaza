module Plaza
  module Connection

    def self.for(config_sym= :default)
      config = Plaza.configuration(config_sym)
      Faraday.new(config.base_url) do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/

        config.middleware.each do |middleware|
          conn.use middleware
        end
        conn.use :http_cache, store: config.cache_store, logger: config.logger

        conn.headers[:accept] = 'application/json'

        conn.adapter Faraday.default_adapter
      end
    end

  end
end
