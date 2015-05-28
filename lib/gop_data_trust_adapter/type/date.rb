module GopDataTrustAdapter

  module Type

    class Date < Base

      ##
      #
      # Convert Value to Date Object.

      def sanitize

        case self.value
        when ::Numeric
          if self.format == :number
            @value = ::Date.strptime(self.value.to_s, '%Y%m%d')
          else
            @value = ::Time.at(self.value).to_date
          end
        when ::String
          if self.value.eql?("")
            @value = nil
          elsif self.format == :no_dash
            @value = ::Date.strptime(self.value.gsub("-", ""), '%Y%m%d')
          else
            @value = ::Date.strptime(self.value, '%Y-%m-%d')
          end
        when ::Time, ::DateTime
          @value = self.value.to_date
        when ::Date
          # Do Nothing in Correct Format
        when NilClass
          # Do Nothing Keep Nil
        else
          @value = ::Date.today
        end

      end

      ##
      #
      # Convert Date object to string, make sure
      # to use correct format, and then single
      # quote the result.

      def safe_value
        if self.value.nil?
          result = ""
        elsif self.format == :no_dash || self.format == :number
          result = self.value.strftime("%Y%m%d")
        else
          result = self.value.strftime("%Y-%m-%d")
        end

        if self.format == :number
          result.to_i.to_s
        else
          self.single_quoter_switch(result)
        end
      end

    end

  end

end