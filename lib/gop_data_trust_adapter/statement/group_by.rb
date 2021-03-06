module GopDataTrustAdapter

  module Statement

    ##
    #
    # Class that handles the GROUP BY statement for a
    # query class.
    class GroupBy < Base

      def initialize *args
        self.statement = []
        super(*args)
      end

      def add_grouping *columns
        columns.each do |column|
          if GopDataTrustAdapter::Table[column.to_sym]
            self.statement << column
          end
        end
      end

      def safe_statement
        statement.join(",")
      end

    end

  end

end