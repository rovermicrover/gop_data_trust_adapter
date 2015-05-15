module GopDataTrustAdapter

  module Type

    class DateTime < Base

      ##
      #
      # Convert Values to Date Object

      def sanitize

        case self.value
        when ::Numeric
          @value = ::DateTime.jd(self.value)
        when ::String
          @value = ::DateTime.strptime(self.value, '%Y-%m-%d %H:%M:%S.%L')
        when ::Time
          @value = ::DateTime.parse(self.value.to_s)
        when ::Date
          @value = self.value.to_datetime
        when ::DateTime
          # Do Nothing in Correct Format
        else
          @value = ::DateTime.now
        end

      end

      ##
      #
      # Convert DateTime object to string, and then single
      # quote the result.

      def safe_value
        unless self.value.nil?
          self.single_quoter_switch(self.value.strftime("%Y-%m-%d %H:%M:%S.%L"))
        end
      end

    end

  end

end