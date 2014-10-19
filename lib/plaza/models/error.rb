module Plaza
  class Error < ::StandardError
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message  = message || "Failed."
      @message << "  Response code = #{status}." if status
    end

    def status
      response.respond_to?(:status) ? response.status : nil
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
