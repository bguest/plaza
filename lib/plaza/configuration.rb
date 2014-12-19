require 'logger'

module Plaza
  class Configuration

    #things that do have defaults only get writers
    attr_writer :use_cache, :cache_entity_store, :cache_meta_store

    def base_url(url = nil)
      url ? @url = url : @url
    end
    alias_method :base_url=, :base_url

    def logger(logger = nil)
      @logger ||= Logger.new(STDOUT)
      logger ? @logger = logger : @logger
    end
    alias_method :logger=, :logger

    def cache_store(store = nil)
      store ? @cache_store = store : @cache_store
    end
    alias_method :cache_store=, :cache_store

  end
end
