module GopDataTrustAdapter

  module Statement

    class Limit < Base

      def initialize *args
        self.statement = 5
        super(*args)
      end

      def set_limit _limit
        self.statement = _limit.to_i
      end


    end

  end

end