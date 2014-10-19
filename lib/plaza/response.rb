require 'delegate'

module Plaza
  class Response < SimpleDelegator
    def success?
      status.to_s[0].to_i == 2
    end

    def redirected?
      status.to_s[0].to_i == 3
    end

    def failed?
      [4, 5].include?(status.to_s[0].to_i)
    end

    def to_str
      body.to_s
    end

    def code
      status
    end

    private
    def object
      __getobj__
    end
  end
end
