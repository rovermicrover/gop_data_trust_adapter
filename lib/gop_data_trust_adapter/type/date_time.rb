module GopDataTrustAdapter

  module Type

    class DateTime < Base

      #################
      # Convert Values to Date Object
      def sanitize

        case self.value
        when BigDecimal, Float, Integer
          @value = Time.at(self.value).to_date
        when String
          @value = Date.strptime(value, '%Y-%m-%d %H:%M:%S.%L')
        when Time, DateTime
          @value = self.value.to_date
        when Date
          # Do Nothing in Correct Format
        else
          @value = Date.today
        end

      end

      def safe_value
        self.value.strftime("'%Y-%m-%d %H:%M:%S.%L'")
      end

    end

  end

end