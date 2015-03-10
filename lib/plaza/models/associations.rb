module Plaza
  module Associations

    def self.included(base)
      # base.class_eval do
      # end
      base.extend ClassMethods
    end

    module ClassMethods
      # Class Configuration
      #
      def has_many(*relations)
        relations.each do |r|
          define_method(sym = association_symbol_for(r)) do
            class_for(r).collection(adapter.has_many(self.id,sym))
          end
        end
      end

      def belongs_to(*relations)
        relations.each do |r|
          define_method(sym = association_symbol_for(r)) do
            class_for(r).find(self.send("#{sym}_id"))
          end
        end
      end

      private

      def association_symbol_for(identifier)
        if identifier.kind_of?(Class) && identifier.respond_to?(:plural_name)
          identifier.plural_name
        elsif identifier.kind_of? String
          Inflector.tableize(identifier.split('::').last)
        elsif identifier.kind_of? Symbol
          identifier
        else
          raise TypeError.new("Can't convert to association symbol")
        end
      end
    end

    protected
    def namespace
      namespace = self.class.to_s.split("::")[0...-1].join("::")
      Kernel.const_get(namespace) unless namespace.empty?
    end
    def class_for(identifier)
      if identifier.kind_of?(Symbol)
        _name = Plaza::Inflector.classify(identifier.to_s)
        if namespace && namespace.const_defined?(_name)
          klass = namespace.const_get(_name)
        else
          klass = Kernel.const_get(_name)
        end
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
