module GopDataTrustAdapter

  class Record

    attr_reader :attributes, :api

    def initialize(_api, _attributes)
      @api = _api
      @attributes = OpenStruct.new()
      _attributes.each do |column, value|
        column = column.to_sym
        if (column_info = Table[column])
          @attributes[column] = Table.type_conversion[column_info.type].new(:value => value, :format => column_info.format)
        end
      end
    end

    ############
    #Delgation to attributes
    def method_missing(method, *args, &block)
      if self.attributes[method]
        self.attributes[method].value
      elsif Table.columns[method]
        nil
      else
        super
      end
    end

  end

end