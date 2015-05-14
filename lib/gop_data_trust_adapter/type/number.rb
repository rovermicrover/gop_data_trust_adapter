module GopDataTrustAdapter

  module Type

    class Number < Base

      #################
      # Force all values to ints
      def sanitize

        @value = self.value.to_i

      end

      def safe_value
        unless self.value.nil?
          self.value.to_s
        end
      end

    end

  end

end