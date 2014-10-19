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

    def use_cache?
      @use_cache ||= false
    end

    def cache_meta_store
      @cache_meta_store ||= 'file:/tmp/cache/meta'
    end

    def cache_entity_store
      @cache_meta_store ||= 'file:/tmp/cache/body'
    end

  end
end
