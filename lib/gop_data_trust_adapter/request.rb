module GopDataTrustAdapter

  ##
  #
  # Class that wraps the request to be sent to DataTrust
  class Request

    attr_reader :api, :https_method, :method, :params

    def initialize(_api, _https_method, _method, _params={})
      @api = _api
      @https_method = _https_method
      @method = _method
      @params = _params
    end

    ##
    #
    # Parse out method and params into a format that
    # works with http library.

    def http_parse_args
      [(self.api.base_url + self.method), self.params]
    end

    ##
    #
    # Wrapper method for http library's request method.

    def get_response
      _response = HTTParty.send(self.https_method, *self.http_parse_args)
      GopDataTrustAdapter::Response.new(self.api, _response)
    end

    def response
      @response ||= self.get_response
    end

    def reload
      @response = self.get_response
    end

    ##
    #
    #Delgation to Response through request

    def method_missing(method_name, *args, &block)
      if Response.instance_methods(false).include?(method_name) || Array.instance_methods(false).include?(method_name)
        self.response.send(method_name, *args, &block)
      else
        super
      end
    end

    ##
    #
    #Make sure respond_to? includes deleged methods

    def respond_to_missing?(method_name, include_private = false)
      Response.instance_methods(false).include?(method_name) || Array.instance_methods(false).include?(method_name) || super
    end

  end

end