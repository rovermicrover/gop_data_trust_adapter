module GopDataTrustAdapter

  class Response

    attr_reader :api, :response, :debug_results,
                :body, :error, :success,
                :call_id, :results, :num,
                :more, :pk_id, :header, :records

    def initialize(_api, _response)
      @api = _api
      @response = _response
      if response.parsed_response.is_a?(String)
        @body = JSON.parse(response.body)
      else
        @body = response.parsed_response
      end
      @header = response.header
      @error = @body["Error"]
      @success = @body["Success"]
      @call_id = @body["Call_ID"]
      @results = @body["Results"] || []
      @num = @body["Results_Count"]
      @more = @body["More_Results"]
      @pk_id = @body["PK_ID"]

      @records = []
      @body["Results"].to_a.each do |r|
        @records << OpenStruct.new(r)
      end
    end

    def debug
      if debug_results.nil? && !@error.nil?
        params = {
          :query => {
            "ClientToken" => api.token,
            "Call_ID" => call_id
          }
        }
        debug_response = HTTParty.get(api.base_url + 'get_call.php', params)
        temp_debug_results = debug_response.parsed_response
        if temp_debug_results["Error"]
          debug_results = @error
        else
          if temp_debug_results.is_a?(String)
            debug_results = JSON.parse(temp_debug_results)
          else
            debug_results = temp_debug_results
          end
        end
      end

      debug_results
    end

    def success?
      success && error.nil?
    end

    def fail?
      !success?
    end

    ############
    #Delgation to records
    def method_missing(method, *args, &block)
      if self.records.class.instance_methods.include?(method)
        self.records.send(method, *args, &block)
      else
        super
      end
    end

  end

end