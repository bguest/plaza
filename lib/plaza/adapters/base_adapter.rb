module Plaza
  module BaseAdapter
    def handle_response
      response = yield
      if response.success?
        return response_to_hash(response)
      else
        handle_error(response)
      end
    end

    def handle_error(response)
      response_hash =  response_to_hash(response)
      error_hash = response_hash.has_key?(:error) ? response_hash[:error] : response_hash["error"]
      unless error_hash
        error_hash = response_hash.has_key?(:errors) ? response_hash[:errors] : response_hash["errors"]
      end

      #test for both singular error and plural errors
      logger.warn("Response returned an error code #{response.code} - #{response_hash}")
      case response.code
        when 422
          error = Plaza::ResourceInvalid.new(response, "#{error_hash}", error_hash)
      else
        error = Plaza::Error.new(response, "#{error_hash}")
      end
      raise(error,error.to_s )
    end

    def response_to_hash(response)
      begin
        if response.body.kind_of? Hash
          response.body
        else
          JSON.parse(response)
        end
      rescue JSON::ParserError=> jsonError
        error = Plaza::Error.new(jsonError, jsonError.message)
        raise(error, error.to_s )
      end
    end
  end
end
