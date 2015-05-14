module GopDataTrustAdapter

  module Type

    class Date < Base

      #################
      # Convert Values to Date Object
      def sanitize

        case self.value
        when ::Numeric
          @value = ::Time.at(self.value).to_date
        when ::String
          @value = ::Date.strptime(self.value, '%Y-%m-%d')
        when ::Time, ::DateTime
          @value = self.value.to_date
        when ::Date
          # Do Nothing in Correct Format
        else
          @value = ::Date.today
        end

      end

      def safe_value
        unless self.value.nil?
          if self.format == :no_dash
            result = self.value.strftime("%Y%m%d")
          else
            result = self.value.strftime("%Y-%m-%d")
          end
          self.single_quoter_switch(result)
        end
      end

    end

  end

end