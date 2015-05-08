module GopDataTrustAdapter

  module Type

    class Date < Base

      #################
      # Convert Values to Date Object
      def sanitize

        case self.value
        when BigDecimal, Float, Integer
          @value = Time.at(self.value).to_date
        when String
          @value = Date.strptime(value, '%Y-%m-%d')
        when Time, DateTime
          @value = self.value.to_date
        when Date
          # Do Nothing in Correct Format
        else
          @value = Date.today
        end

      end

      def safe_value
        if self.format == :no_dash
          self.value.strftime("'%Y%m%d'")
        else
          self.value.strftime("'%Y-%m-%d'")
        end
      end

    end

  end

end