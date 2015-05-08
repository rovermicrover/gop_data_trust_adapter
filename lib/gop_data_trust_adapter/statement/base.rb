module GopDataTrustAdapter

  module Statement

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