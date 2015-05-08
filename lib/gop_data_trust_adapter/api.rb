require 'gop_data_trust_adapter/table'
require 'gop_data_trust_adapter/query'
require 'gop_data_trust_adapter/response'

module GopDataTrustAdapter

  class Api

    class << self

      # For Thread Safety Must Reconnect On Every New Thread
      def connect options={}

        Thread.current["GopDataTrust/Api/@@test"] = options[:test]
        Thread.current["GopDataTrust/Api/@@token"] = (options[:token] || ENV["GopDataTrustToken"])
        if options[:production].eql?(true) || (options[:production].nil? && ENV["GopDataTrustProduction"])
          Thread.current["GopDataTrust/Api/@@base_url"] = "https://www.gopdatatrust.com/v2/api/"
        else
          Thread.current["GopDataTrust/Api/@@base_url"] = "https://lincoln.gopdatatrust.com/v2/api/"
        end


        nil
      end

      def token
        Thread.current["GopDataTrust/Api/@@token"] || connect
        raise "Must Connect To GOP Data Trust" if Thread.current["GopDataTrust/Api/@@token"].nil?
        Thread.current["GopDataTrust/Api/@@token"]
      end

      def base_url
        Thread.current["GopDataTrust/Api/@@base_url"] || connect
        raise "Must Connect To GOP Data Trust" if Thread.current["GopDataTrust/Api/@@base_url"].nil?
        Thread.current["GopDataTrust/Api/@@base_url"]
      end

      def test?
        !Thread.current["GopDataTrust/Api/@@test"].nil?
      end

      def get method, params={}
       self.http_request :get, method, params
      end

      def post method, params={}
        self.http_request :post, method, params
      end

      def put method, params={}
        self.http_request :put, method, params
      end

      def http_parse_args method, params={}
        [self.base_url + method, params]
      end

      def http_request https_method, method, params={}
        args = self.http_parse_args(method, params)
        if self.test?
          result = args
        else
          response = HTTParty.send(https_method, *args)
          result = GopDataTrustAdapter::Response.new(self, response)
        end
        result
      end

      ############
      #Delgation to Query
      def method_missing(method, *args, &block)
        if GopDataTrustAdapter::Query.instance_methods(false).include?(method)
          GopDataTrustAdapter::Query.new(self).send(method, *args, &block)
        else
          super
        end
      end

      #############
      #Read Methods
      def query q, params={}
        params = {
          :query => {
            "ClientToken" => self.token,
            "q" => q,
            "Call_ID" => params[:call_id],
            "format" => params[:format]
          }
        }
        get 'query.php', params
      end

      def find first_name, last_name, params={}
        params = {
          :query => {
            "ClientToken" => self.token,
            "FirstName" => first_name,
            "MiddleName" => params[:middle_name],
            "LastName" => last_name,
            "ReturnFields" => (params[:return_fields] || @@default_fields),
            "Reg_AddressZip5" => params[:zip],
            "DateOfBirth" => params[:date_of_birth].try(:strftime, "%Y%m%d"),
            "Limit" => (params[:limit] || 5)
          }
        }
        get 'fast_match.php', params
      end

      def get_file q, *emails
        params = {
          :query => {
            "ClientToken" => self.token,
            "q" => q,
            "email" => emails.join(",")
          }
        }

        post 'query_get_file.php', params
      end

      #############
      #Write Methods
      def add_tag key, params={}
        params = {
          :body => {
            "ClientToken" => self.token,
            "PersonKey" => key,
            "ElementYear" => params[:year],
            "ElementName" => params[:name],
            "ElementDescription" => params[:desc]
          }
        }

        post 'add_tag.php', params
      end

      def add_voter_contact key_type, key, params={}
        params = {
          :body => {
            "ClientToken" => self.token,
            "ContactType" => params[:type],
            "ContactDisposition" => params[:disposition],
            "ContactDate" => params[:date],
            "ContactTime" => params[:time],
            key_type => key,
            "StateAbbreviation" => params[:state_abbreviation],
            "OfficeName" => params[:office_name],
            "InitiativeName" => params[:initiative_name],
            "UniverseName" => params[:universe_name]
          }
        }

        post 'add_voter_contact.php', params
      end

      def set_email email, key
        params = {
          :query => {
            "ClientToken" => self.token,
            "EmailAddress" => email,
            "PersonKey" => key
          }
        }
        put 'set_email.php', params
      end

      def set_phone phone, key
        params = {
          :query => {
            "ClientToken" => self.token,
            "PhoneNumber" => phone,
            "PersonKey" => key
          }
        }

        put 'set_phone.php', params
      end

      def set_address type, key, params={}
        params = {
          :query => {
            "ClientToken" => self.token,
            "AddressType" => type,
            "VoterKey" => key,
            "AddressLine1" => params[:address_1],
            "AddressLine2" => params[:address_2],
            "AddressCity" => params[:city],
            "AddressState" => params[:state],
            "AddressZip5" => params[:zip5],
            "AddressZip4" => params[:zip4]
          }
        }

        put 'set_address.php', params
      end

      def direct_write action, field, params={}
        params = {
          :query => {
            "ClientToken" => self.token,
            "Action" => action,
            "PK_Field" => field,
            "Call_ID" => params[:call_id],
            "pk_id" => params[:pk_id],
            "Values" => params[:values].try(:to_json),
            "Leave_Open" => params[:leave_open],
            "Rationale" => params[:rationale]
          }
        }

        put 'direct_write.php', params
      end

    end

  end

end