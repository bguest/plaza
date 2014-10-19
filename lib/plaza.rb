require 'virtus'
require "rack/cache"

require 'plaza/configuration'
require "plaza/version"
require 'plaza/models'
require 'plaza/request'
require 'plaza/response'
require 'plaza/adapters'
require 'plaza/inflector'
require 'restclient/components'

module Plaza

  class << self
    def enable_cache
      #this makes it so that we adhere to http cache headers when issuing
      #requests
      require 'rack/cache'
      RestClient.enable Rack::Cache,
        :metastore => self.configuration.meta_store,
        :entitystore =>  self.configuration.entity_store
    end
  end

  def self.configuration(component_name = :default)
    @configurations ||= {}
    @configurations[component_name] ||= Plaza::Configuration.new
  end

  def self.configure(component_name = :default, &block)
    self.configuration(component_name).instance_eval(&block) if block_given?
  end

  def self.adapter(class_name)
    Plaza.const_get("#{class_name}Adapter").new
  end

end
