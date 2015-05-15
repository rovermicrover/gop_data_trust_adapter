require 'gop_data_trust_adapter/record'

module GopDataTrustAdapter

  ##
  #
  # Class that wraps the returned response from DataTrust

  class Response

    attr_reader :api, :response, :debug_results,
                :body, :error, :success,
                :call_id, :results, :num,
                :more, :pk_id, :header, :records,
                :contact_key

    def initialize(_api, _response)
      @api = _api
      @response = _response
      @body = JSON.parse(response.body) if response.body
      @header = response.header
      @error = @body["Error"]
      @success = @body["Success"]
      @call_id = @body["Call_ID"]
      @results = @body["Results"] || []
      @num = @body["Results_Count"]
      @more = @body["More_Results"]
      @pk_id = @body["PK_ID"]
      @contact_key = @body["ContactKey"]

      @records = []
      @body["Results"].to_a.each do |r|
        @records << Record.new(api, r)
      end
    end

    ##
    #
    # If there is an error on response retrieve
    # info on the failed call from the DataTrust.

    def debug
      if !@error.nil?
        api.get_call(self.call_id)
      else
        nil
      end
    end

    def success?
      success && error.nil?
    end

    def fail?
      !success? || !error.nil?
    end

    ##
    #
    #Delegation to records.

    def method_missing(method_name, *args, &block)
      if self.records.class.instance_methods.include?(method_name)
        self.records.send(method_name, *args, &block)
      else
        super
      end
    end

    ##
    #
    #Make sure respond_to? includes delegation methods.

    def respond_to_missing?(method_name, include_private = false)
      self.records.class.instance_methods.include?(method_name) || super
    end

  end

end