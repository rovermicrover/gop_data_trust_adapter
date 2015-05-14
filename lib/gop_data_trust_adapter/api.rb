require 'gop_data_trust_adapter/table'
require 'gop_data_trust_adapter/query'
require 'gop_data_trust_adapter/response'

module GopDataTrustAdapter

  class Api

    class << self

      @@default_token = ENV["GopDataTrustToken"]

      def default_token
        @@default_token
      end

      def default_token= value
        @@default_token = value
      end

      @@default_production = ENV["GopDataTrustProduction"]

      def default_production?
        @@default_production
      end

      def default_production= value
        @@default_production = value
      end

      # For Thread Safety Must Reconnect On Every New Thread
      def connect options={}

        Thread.current["GopDataTrust/Api/@@test"] = options[:test]
        Thread.current["GopDataTrust/Api/@@token"] = (options[:token] || self.default_token)
        if options[:production].eql?(true) || (options[:production].nil? && self.default_production?)
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

      # firstname lastname required
      def fast_match params={}
        dob = (params[:dateofbirth] || params[:date_of_birth])
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "FirstName" => Type::String.safe_value(params[:firstname] || params[:first_name], opts),
            "MiddleName" => Type::String.safe_value(params[:middlename] || params[:middle_name], opts),
            "LastName" => Type::String.safe_value(params[:lastname] || params[:last_name], opts),
            "ReturnFields" => (params[:return_fields] || Table.default_fields),
            "Reg_AddressZip5" => Type::String.safe_value(params[:reg_addresszip5] || params[:zip], opts),
            "DateOfBirth" => Type::Date.safe_value(dob, opts.merge(:format => :no_dash)),
            "Limit" => Type::Number.safe_value(params[:limit] || 5)
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
        opts = {:single_quoted => false}
        params = {
          :body => {
            "ClientToken" => self.token,
            "PersonKey" => Type::String.safe_value(key, opts),
            "ElementYear" => Type::Number.safe_value(params[:year], opts),
            "ElementName" => Type::String.safe_value(params[:name], opts),
            "ElementDescription" => Type::String.safe_value(params[:desc], opts)
          }
        }

        post 'add_tag.php', params
      end

      def add_voter_contact key_type, key, params={}
        opts = {:single_quoted => false}
        if (params[:date_time] || params[:datetime])
          date_time = Type::DateTime.new(params[:date_time] || params[:datetime]).value
          params[:date] = date_time.to_date
          params[:time] = date_time.strftime("%H:%M:%S")
        end
        params = {
          :body => {
            "ClientToken" => Type::String.safe_value(self.token, opts),
            Type::String.safe_value(key_type, opts) => Type::String.safe_value(key, opts),
            "ContactType" => Type::String.safe_value(params[:type], opts),
            "ContactDisposition" => Type::String.safe_value(params[:disposition], opts),
            "ContactDate" => Type::Date.safe_value(params[:date], opts),
            "ContactTime" => Type::String.safe_value(params[:time], opts),
            "StateAbbreviation" => Type::String.safe_value(params[:state_abbreviation], opts),
            "OfficeName" => Type::String.safe_value(params[:office_name], opts),
            "InitiativeName" => Type::String.safe_value(params[:initiative_name], opts),
            "UniverseName" => Type::String.safe_value(params[:universe_name], opts)
          }
        }

        post 'add_voter_contact.php', params
      end

      def set_email email, key
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "EmailAddress" => Type::String.safe_value(email, opts),
            "PersonKey" => Type::String.safe_value(key, opts)
          }
        }
        put 'set_email.php', params
      end

      def set_phone phone, key
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "PhoneNumber" => Type::String.safe_value(phone, opts),
            "PersonKey" => Type::String.safe_value(key, opts)
          }
        }

        put 'set_phone.php', params
      end

      def set_address type, key, params={}
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "AddressType" => Type::String.safe_value(type, opts),
            "VoterKey" => Type::String.safe_value(key, opts),
            "AddressLine1" => Type::String.safe_value(params[:address_1], opts),
            "AddressLine2" => Type::String.safe_value(params[:address_2], opts),
            "AddressCity" => Type::String.safe_value(params[:city], opts),
            "AddressState" => Type::String.safe_value(params[:state], opts),
            "AddressZip5" => Type::String.safe_value(params[:zip5], opts),
            "AddressZip4" => Type::String.safe_value(params[:zip4], opts)
          }
        }

        put 'set_address.php', params
      end

      def direct_write action, field, params={}
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "Action" => Type::String.safe_value(action, opts),
            "PK_Field" => Type::String.safe_value(field, opts),
            "Call_ID" => Type::String.safe_value(params[:call_id], opts),
            "pk_id" => Type::String.safe_value(params[:pk_id], opts),
            "Values" => (params[:values].to_json if params[:values]),
            "Leave_Open" => Type::String.safe_value(params[:leave_open], opts),
            "Rationale" => Type::String.safe_value(params[:rationale], opts)
          }
        }

        put 'direct_write.php', params
      end

      def debug call_id
        opts = {:single_quoted => false}
        params = {
          :query => {
            "ClientToken" => self.token,
            "Call_ID" => Type::String.safe_value(call_id, opts)
          }
        }

        get 'get_call.php', params
      end

    end

  end

end