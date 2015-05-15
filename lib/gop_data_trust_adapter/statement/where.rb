module GopDataTrustAdapter

  module Statement

    ##
    #
    # Class that handles WHERE statements for a
    # query class.
    class Where < Base

      LOGICALOPERATIONS = ["AND", "OR"]

      attr_reader :or

      def next_or
        @or = true
      end

      def add_where_statement columns_values={}, *args
        if columns_values.is_a?(String)
          args.each do |arg|

            attributes = {}

            case arg
            when Array
              attributes[:value] = arg[0]
              attributes[:format] = arg[1]
            when Hash
              attributes = arg
            else
              attributes[:value] = arg
            end

            klass_sanitizer = GopDataTrustAdapter::Table.class_conversion.values_at(*attributes[:value].class.ancestors).compact.first

            klass_sanitizer ||= GopDataTrustAdapter::Table.class_conversion_default

            sanitizer = klass_sanitizer.new(attributes)

            columns_values.sub!("?", sanitizer.safe_value)
          end
          self.statement =  self.statement.to_s + " #{@or ? "OR" : "AND"} " + columns_values
        else
          columns_values.each do |column, value|
            if (column_info = GopDataTrustAdapter::Table[column.to_sym])
              parsed_value = GopDataTrustAdapter::Table.type_conversion[column_info.type].new(:value => value, :format => column_info.format)
              self.statement = self.statement.to_s + " #{@or ? "OR" : "AND"} #{column} = #{parsed_value.safe_value}"
            end
          end
        end
        @or = false
      end

      def safe_statement
        #Remove the leading logical operator.
        safe_statement = nil
        LOGICALOPERATIONS.each do |lo|
          reg = Regexp.new("\\A " + lo)
          safe_statement = (safe_statement || self.statement).gsub(reg, "")
        end

        safe_statement.strip
      end

      def dup
        the_dup = super
        the_dup.instance_variable_set(:@or, self.or)
        the_dup
      end

    end

  end

end