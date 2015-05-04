module Plaza
  class Error < ::RuntimeError
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message  = message || "Failed."
      @message << "  Response code = #{status}." if status
    end

    def status
      if response.kind_of?(Hash)
       response[:status]
      else
        response.respond_to?(:code) ? response.code : nil
      end
    end

    def to_s
      @message
    end
    alias :to_str :to_s
  end


  class ConnectionError < Error; end

  #422
  class ResourceInvalid < Error
    attr_reader :errors
    def initialize(response, message = nil, error_hash={})
      super(response, message)
      @errors = error_hash
    end

  end
end
