require 'gop_data_trust_adapter/table'
require 'gop_data_trust_adapter/query'
require 'gop_data_trust_adapter/request'
require 'gop_data_trust_adapter/response'

module GopDataTrustAdapter

  ##
  # This class is responsible for top level management of
  # credentials, and for manging all requests.

  class Api

    class << self

      @@default_token = ENV["GopDataTrustToken"]

      ##
      # Gets Default Token, stored as a class varible, so aviable accross threads.
      # Will be used when no token option is passed to connect.

      def default_token
        @@default_token
      end

      ##
      # Sets Default Token, stored as a class varible, so aviable accross threads.

      def default_token= value
        @@default_token = value
      end

      @@default_production = ENV["GopDataTrustProduction"]

      ##
      # Gets Default Production?, stored as a class varible, so aviable accross threads.
      # Will be used when no production option is passed to connect.
      # When false will use lincoln staging url, otherwise uses live data trust url

      def default_production?
        @@default_production
      end

      def default_production= value
        @@default_production = value
      end

      ##
      # For Thread Safety Must Reconnect On Every New Thread

      def connect options={}

        Thread.current["GopDataTrust/Api/@token"] = (options[:token] || self.default_token)
        if options[:production].eql?(true) || (options[:production].nil? && self.default_production?)
          Thread.current["GopDataTrust/Api/@base_url"] = "https://www.gopdatatrust.com/v2/api/"
        else
          Thread.current["GopDataTrust/Api/@base_url"] = "https://lincoln.gopdatatrust.com/v2/api/"
        end


        nil
      end

      ##
      # Attempt to get token for API on this thread, if not present force connection
      # based on default values, and return that value.
      def token
        Thread.current["GopDataTrust/Api/@token"] || connect
        raise "Must Connect To GOP Data Trust" if Thread.current["GopDataTrust/Api/@token"].nil?
        Thread.current["GopDataTrust/Api/@token"]
      end

      ##
      # Attempt to get base_url for API on this thread, if not present force connection
      # based on default values, and return that value.
      def base_url
        Thread.current["GopDataTrust/Api/@base_url"] || connect
        raise "Must Connect To GOP Data Trust" if Thread.current["GopDataTrust/Api/@base_url"].nil?
        Thread.current["GopDataTrust/Api/@base_url"]
      end

      ##
      #
      # Wrapper method for http library's get method.

      def get method, params={}
        Request.new(self, :get, method, params)
      end

      ##
      #
      # Wrapper method for http library's post method.

      def post method, params={}
        Request.new(self, :post, method, params)
      end

      ##
      #
      # Wrapper method for http library's put method.

      def put method, params={}
        Request.new(self, :put, method, params)
      end


      ##
      #
      #Delegation to Query class.

      def method_missing(method_name, *args, &block)
        if Query.instance_methods(false).include?(method_name)
          Query.new(self).send(method_name, *args, &block)
        else
          super
        end
      end

      ##
      #
      #Make sure respond_to? includes deleged methods

      def respond_to_missing?(method_name, include_private = false)
        Query.instance_methods(false).include?(method_name) || super
      end

      ##
      #
      # Follows DataTrust docs but all params and attributes are now down-cased symbols
      #
      # So "FirstName" becomes :firstname
      #
      # Also for this method q is not a param but rather the first passed value
      #
      # From Data Trust
      #
      # Usage
      #   Raw access to reading from our data warehouse. Intended to be both flexible and simple to use.
      #   Based upon the token provided, your query will be limited to the fields and geographies you have access to.
      #   Pages of 5,000 results are returned at a time
      #   Maximum LIMIT is 50,000. If you'd like to get more than 50,0000 results, please see query_get_file.php
      #
      # Required Parameters
      #   ClientToken
      #   q
      #     This parameter's value should be specified in DQL (similar to SQL).
      #     Valid fields can be found below.
      #     SELECT and LIMIT required. WHERE, SELECT DISTINCT, COUNT(), COUNT(DISTINCT), and GROUP BY are all supported. Note: you cannot SELECT *.
      #     Utilize single quotes around string comparisons in WHERE statements
      #     A properly formed call would look like: SELECT firstname,COUNT(*) WHERE ( (stateabbreviation='VA' AND congressionaldistrict='1') OR stateabbreviation='MA' ) AND lastname~'%Smith%' GROUP BY firstname LIMIT 10000
      #     Allowed operators in a WHERE statement include =, !=, >, >=, <, <=, ~, and !~. The wildcard character for a string comparison using ~ or !~ is %.
      #     FROM and LEFT JOIN statements are not required (or supported)
      #     * can only be used within a count
      #   Call_ID
      #     If More_Results on a previous request was true, you can specify the Call_ID to continue returning results. This parameter can be specified in the place of 'q'.
      #
      # Optional Parameters
      #   format
      #     JSON (default)
      #     CSV
      #     XML
      #   Dont_Wrap
      #     returns just the result, not wrapped in a JSON container (not recommended)
      #
      # Returns (JSON, unless Dont_Wrap specified)
      #   Call_ID
      #   Success
      #     true or false
      #   Results
      #     contains result (depending on format)
      #   Results_Count
      #     Number of results returned. For a full count of a LIMITed query, perform a separate query
      #   More_Results
      #     true or false
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

      ##
      #
      # Follows DataTrust docs but all params and attributes are now down-cased symbols
      #
      # So "FirstName" becomes :firstname
      #
      # From Data Trust
      #
      # Usage
      #   Intended to provide a quick match identifiable information to a subset of Data Trust's voter data.
      #   Should always return sub-second, and requests can be parallelized to complete batch operations faster.
      #   Billed in the exact same way as a normal DQL query
      #   If more than 5 people match your query, only personkeys will be returned
      #
      # Required Parameters
      #   ClientToken
      #   FirstName
      #   LastName
      #   ReturnFields
      #     Comma delimited
      #     Valid values: phonenumber, emailaddress, reg_addressline1, reg_addressline2, reg_addressstate, reg_addresszip5, reg_addresszip4, rnc_regid, party, rnccalcparty, statevoteridnumber, firstname, middlename, lastname, phonenumber, emailaddress, dateofbirth, sex
      #   Limit
      #     Limit the number of results returned
      #
      # Optional Parameters
      #   Reg_AddressZip5
      #   MiddleName
      #     or just middle initial
      #   DateOfBirth
      #     YYYYMMDD or YYYYMM or YYYY
      #
      # Returns (JSON)
      #   Call_ID
      #   Success
      #     true or false
      #   Results
      #   Results_Count
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