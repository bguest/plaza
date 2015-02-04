require 'logger'

module Plaza
  class Configuration

    attr_accessor :middleware
    attr_accessor :default_middleware

    def initialize
      @default_middleware = [
        Plaza::Middleware::Exceptions,
        Plaza::Middleware::UserId
      ]
      @middleware = []
    end

    def middleware
      @middleware + default_middleware
    end

    def base_url(url = nil)
      url ? @url = url : @url
    end
    alias_method :base_url=, :base_url

    def cache_store(store = nil)
      store ? @cache_store = store : @cache_store
    end
    alias_method :cache_store=, :cache_store

    def logger(logger = nil)
      @logger ||= Logger.new(STDOUT)
      logger ? @logger = logger : @logger
    end
    alias_method :logger=, :logger

    def use(*ware)
      @middleware << ware
      @middleware.flatten!
    end
  end
end
