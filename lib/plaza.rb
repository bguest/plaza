require 'virtus'

require 'plaza/configuration'
require "plaza/version"
require 'plaza/models'
require 'plaza/request'
require 'plaza/response'
require 'plaza/adapters'
require 'plaza/inflector'
require 'plaza/connection'

module Plaza

  def self.configuration(component_name = :default)
    @configurations ||= {}
    @configurations[component_name] ||= Plaza::Configuration.new
  end

  def self.configure(component_name = :default, &block)
    self.configuration(component_name).instance_eval(&block) if block_given?
  end

  def self.connection(component_name = :default)
    @connections ||= {}
    @connections[component_name] ||= Plaza::Connection.for(component_name)
  end

  def self.adapter(class_name)
    Plaza.const_get("#{class_name}Adapter").new
  end

end
