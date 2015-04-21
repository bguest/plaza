module Plaza
  module RestfulModel
    ErrorResponse = Struct.new(:code, :body) do
      def to_str
        body
      end
    end

    def self.included(base)
      base.class_eval do
        include Virtus.model
        include Plaza::BaseModel
        include Plaza::Associations
        attribute :id,     Integer
        attribute :errors, Hash

        def serialize
          attrs = attributes.delete_if{|k, v| k.to_sym == :id && v.nil?}
          attrs = attrs.delete_if{|k, v| self.class.restricted_attributes.include?(k.to_sym)}
          attrs.delete(:errors)
          {singular_name => attrs}
        end
      end

      base.extend ClassMethods
    end

    module ClassMethods

      def all(attributes=nil)
        collection(adapter.index(attributes))
      end

      def find(id)
        self.new( adapter.show(id) )
      end

      def adapter
        Plaza::RestfulAdapter.new(self)
      end

      def create(attributes)
        resource = self.new(attributes)
        resource.save && resource
      end

      def where(attributes)
        all(attributes)
      end

      def plural_name
        Inflector.pluralize(singular_name)
      end

      def singular_name
        self.to_s.split('::').last.scan(/[A-Z][a-z]+/).join('_').downcase
      end

      def restricted_attributes(*args)
        @restricted_attributes ||= []
        !args.empty? ? @restricted_attributes = args : @restricted_attributes
      end

      def plaza_config(config = nil)
        @plaza_config ||= :default
        config ? @plaza_config = config : @plaza_config
      end

      alias_method :plaza_config=, :plaza_config

    end

    def plaza_config
      self.class.plaza_config
    end

    def delete
      self.class.adapter.delete(self.id)
    end

    def error_messages
      if errors.empty?
        []
      else
        errors.collect{|k, v| v.collect{|val| "#{k} #{val}"}}.flatten
      end
    end

    def new_record?
      self.id.nil?
    end

    def persisted?
      !new_record?
    end

    def save
      self.errors = {}
      begin
        if persisted?
          self.attributes = self.class.adapter.update(self.id, self.serialize)
        else
          self.attributes = self.class.adapter.create(self.serialize)
        end
      rescue Plaza::ResourceInvalid => e
        self.errors.merge!(e.errors)
      end
      self.errors.empty?
    end

    def symbolize_keys(hash)
      hash.inject({}){|sym_hash,(k,v)| sym_hash[k.to_sym] = v; sym_hash}
    end

    def to_param
      self.id
    end

    def update_attributes(attributes_hash)
      self.attributes = self.attributes.merge(self.symbolize_keys(attributes_hash))
      self.save
    end

    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      if self.respond_to?(method_name + '_id')
        obj_id = self.send(method_name + '_id')
        class_name = Plaza::Inflector.classify(method_name)
        klass = (self.class.name.split('::')[0..-2] + [class_name]).reduce(Module, :const_get)
        return klass.find(obj_id)
      else
        raise NoMethodError.new "undefined method '#{method_name}' for #{self.class}"
      end
    end

    def plural_name
      self.class.plural_name
    end


  end
end
