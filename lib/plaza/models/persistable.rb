module Plaza
  module Persistable
    def self.included(base)
      base.class_eval do
        attribute :id,     Integer
        attribute :errors, Hash
      end
    end

    def new_record?
      self.id.nil?
    end

    def persisted?
      !new_record?
    end

    def save
      #reset errors on every save
      self.errors = {}
      begin
        if persisted?
          self.attributes = adapter.update(self.id, self.serialize)
        else
          self.attributes = adapter.create(self.serialize)
        end
      rescue Plaza::ResourceInvalid => e
        self.errors.merge!(e.errors)
      end
      self.errors.empty?
    end

  end
end