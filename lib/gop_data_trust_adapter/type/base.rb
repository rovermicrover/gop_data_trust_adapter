module GopDataTrustAdapter

  module Type

    class Base

      attr_reader :value
      attr_reader :format
      attr_reader :single_quoted

      def initialize args={}, options={}
        unless args.is_a? Hash
          options[:value] = args
          args = options
        end

        @format = (args[:format] || :default)
        if args[:single_quoted].nil?
          @single_quoted = true
        else
          @single_quoted = args[:single_quoted]
        end

        # This most go last because value relies on format to be set
        self.value = args[:value]
      end

      def self.safe_value args={}, options={}
        self.new(args, options).safe_value
      end

      ##
      #
      # Set value and then sanitize

      def value= _value
        @value = _value
        self.sanitize
        @value
      end

      ###
      #
      # All String Fields Are UTF-8 AND Only Alpha Numeric and White Space.
      # So force UTF-8 and then remove all non Alpha Numeric and White Spaces.
      # Then covert all white space groupings to a single simple space.
      # Then strip leading and ending whitespace

      def sanitize

        @value = @value.to_s.encode(Encoding::UTF_8)
        @value.gsub!(self.class.sanitize_regex,"")
        @value.gsub!(/[[:blank:]]+/," ")
        @value.strip!

      end

      ##
      #
      # Convert value object to string, and then
      # single quote it.

      def safe_value
        self.single_quoter_switch(self.value.to_s)
      end

      ##
      #
      # Put single quote around value
      # unless single_quoted attribute
      # is falsely.
      def single_quoter_switch value
        if self.single_quoted
          "'" + value.to_s + "'"
        else
          value.to_s
        end
      end

      def self.sanitize_regex
        /[^[:alnum:][:blank:]\.@:-]/
      end

    end

  end

end