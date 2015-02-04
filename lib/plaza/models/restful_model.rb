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
        attribute :id,     Integer
        attribute :errors, Hash

        def serialize
          attrs = attributes.delete_if{|k, v| k.to_sym == :id && v.nil?}
          attrs = attrs.delete_if{|k, v| [:updated_at, :created_at].include?(k.to_sym)}
          attrs.delete(:errors)
          {singular_name => attrs}
        end
      end

      base.extend ClassMethods
    end

    module ClassMethods

      def all
        collection(adapter.index)
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
        collection( adapter.index(attributes) )
      end

      def plural_name
        singular_name + 's'
      end

      def singular_name
        self.to_s.split('::').last.scan(/[A-Z][a-z]+/).join('_').downcase
      end

      # Class Configuration
      #
      def has_many(*relations)
        relations.each do |r|
          define_method(sym = has_many_symbol_for(r)) do
            class_for(r).collection(adapter.has_many(self.id,sym))
          end
        end
      end

      def plaza_config(config = nil)
        @plaza_config ||= :default
        config ? @plaza_config = config : @plaza_config
      end

      alias_method :plaza_config=, :plaza_config

      private

      def has_many_symbol_for(identifier)
        if identifier.kind_of? Class
          identifier.plural_name
        elsif identifier.kind_of? String
          Inflector.tableize(identifier.split('::').last)
        elsif identifier.kind_of? Symbol
          identifier
        else
          raise TypeError.new("Can't convert to has_many symbol")
        end
      end


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
      !persisted?
    end

    def persisted?
      self.id.present?
    end

    def save
      begin
        if self.id
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
        return Plaza.const_get(class_name).find(obj_id)
      else
        raise NoMethodError.new "undefined method '#{method_name}' for #{self.class}"
      end
    end

    protected

    def class_for(identifier)
      if identifier.kind_of?(Symbol)
        klass = Plaza.const_get(Plaza::Inflector.classify(identifier.to_s))
      elsif identifier.kind_of?(String)
        klass = Object.const_get(identifier)
      elsif identifier.kind_of?(Class)
        klass = identifier
      else
        raise TypeError.new("Can't convert to has_many relation")
      end
    end

  end
end
