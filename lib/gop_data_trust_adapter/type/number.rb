module GopDataTrustAdapter

  module Type

    class Number < Base

      #################
      # Force all values to ints
      def sanitize

        self.value = self.value.to_i

      end

      def safe_value
        self.value.to_s
      end

    end

  end

end