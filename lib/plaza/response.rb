require 'delegate'

module Plaza
  class Response < SimpleDelegator
    def success?
      code.to_s[0].to_i == 2
    end

    def redirected?
      code.to_s[0].to_i == 3
    end

    def failed?
      [4, 5].include?(code.to_s[0].to_i)
    end

    def to_str
      body.to_s
    end

    def headers
      get_from_method_or_accessor(:headers)
    end

    def body
      get_from_method_or_accessor(:body)
    end

    def code
      get_from_method_or_accessor(:status).to_i
    end

    private
    def object
      __getobj__
    end

    def get_from_method_or_accessor(attribute_symbol)
      object.respond_to?(attribute_symbol) ? object.send(attribute_symbol) : object[attribute_symbol]
    end
  end
end
