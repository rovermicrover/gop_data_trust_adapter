module GopDataTrustAdapter

  module Type

    class Base

      attr_reader :value
      attr_reader :format

      def initialize args={}
        self.value = args[:value]
        @format = (args[:format] || :default)
      end

      def value= _value
        @value = _value
        self.sanitize
        @value
      end

      #################
      # All String Fields Are UTF-8 AND Only Alpa Numberic and White Space.
      # So force UTF-8 and then remove all non Alpha Numberic and White Spaces.
      # Then covert all white space groupings to a single simple space.
      # Then strip leading and ending whitespace
      def sanitize

        @value = @value.encode(Encoding::UTF_8)
        @value.gsub!(/[^[:alnum:][:blank:]]/,"")
        @value.gsub!(/[[:blank:]]+/," ")
        @value.strip!

      end

      def safe_value
        "'" + self.value.to_s + "'"
      end

    end

  end

end