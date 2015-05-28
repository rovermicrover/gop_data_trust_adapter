module GopDataTrustAdapter

  module Type

    class Number < Base

      ##
      #
      # Force all values to Integer

      def sanitize

        @value = self.value.to_i

      end

      ##
      #
      # Convert Integer object to string, don't
      # single quote.

      def safe_value
        self.value.to_i.to_s
      end

    end

  end

end