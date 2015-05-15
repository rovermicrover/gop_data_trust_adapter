module GopDataTrustAdapter

  module Statement

    ##
    #
    # Class that handles the LIMIT statement for a
    # query class.
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