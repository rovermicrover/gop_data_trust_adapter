module GopDataTrustAdapter

  module Statement

    ##
    #
    # Class that handles the SELECT statement for a
    # query class.
    class Select < Base

      attr_reader :distinct

      def initialize *args
        self.statement = []
        super(*args)
      end

      def add_select *columns
        columns.each do |column|
          if GopDataTrustAdapter::Table[column.to_sym]
            self.statement << column
          end
        end
      end

      def add_count *columns
        columns.each do |column|
          if GopDataTrustAdapter::Table[column.to_sym] || column.to_s.eql?("*")
            self.statement << "COUNT(#{column})"
          end
        end
      end

      def safe_statement
        if statement.length == 0
          GopDataTrustAdapter::Table.default_fields.join(",")
        else
          statement.join(",")
        end
      end

      def is_distinct
        @distinct = true
      end

      def dup
        the_dup = super
        the_dup.instance_variable_set(:@distinct, self.distinct)
        the_dup
      end

    end

  end

end