module GopDataTrustAdapter

  module Statement

    ##
    #
    # Class that handles a given statement for a query.
    # Other statement classes inherit for this one.
    # An example of a statement is a WHERE statement, or a
    # SELECT statement. A query is made up of these.
    class Base

      attr_accessor :statement
      attr_reader :collection

      def initialize _collection
        @collection = _collection
      end

      def safe_statement
        statement.to_s.strip
      end

      def dup
        the_dup = self.class.new(self.collection)

        begin
          the_dup.statement = self.statement.dup
        rescue TypeError
          the_dup.statement = self.statement
        end

        the_dup
      end

    end

  end

end