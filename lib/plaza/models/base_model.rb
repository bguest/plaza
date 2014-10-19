module Plaza
  module BaseModel
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      ## assumes a shallow hierarchy where there is only one
      ## root element that contains an array of hashes
      ## For Example:
      ## {:campaign_ranks=>[{:key=>1, :rank=>"0.4"}, {:key=>2, :rank=>"0.9"}]}
      def collection(response)
        response.values.first.collect do |obj|
          self.new(obj)
        end
      end

      def adapter
        Plaza.adapter(self)
      end

    end

    def adapter
      self.class.adapter
    end

    def singular_name
      self.class.to_s.split('::').last.scan(/[A-Z][a-z]+/).join('_').downcase
    end

    def serialize
      {singular_name => attributes}
    end

    def to_json
      self.serialize.to_json
    end
  end
end
