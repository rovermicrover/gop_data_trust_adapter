require 'gop_data_trust_adapter/statements'

module GopDataTrustAdapter

  class Query

    attr_reader :api, :statements

    def initialize(_api)
      @api = _api
      @statements = Statements.new(self)
    end

    def where columns_values={}, *args
      the_dup = self.dup
      the_dup.statements.where.add_where_statement(columns_values, *args)
      the_dup
    end

    def or
      the_dup = self.dup
      the_dup.statements.where.next_or
      the_dup
    end

    def distinct
      the_dup = self.dup
      the_dup.statements.select.is_distinct
      the_dup
    end

    def select *columns
      the_dup = self.dup
      the_dup.statements.select.add_select *columns
      the_dup
    end

    def count *columns
      the_dup = self.dup
      the_dup.statements.select.add_count *columns
      the_dup
    end

    def group_by *columns
      the_dup = self.dup
      the_dup.statements.group_by.add_grouping *columns
      the_dup
    end

    def limit _limit
      the_dup = self.dup
      the_dup.statements.limit.set_limit _limit
      the_dup
    end

    def status
      self.statements.to_h
    end

    def build_query
      query = "SELECT#{self.statements.select.distinct ? ' DISTINCT' : ''} #{self.statements.select.safe_statement}"

      unless self.statements.where.statement.nil?
        query += " WHERE #{self.statements.where.safe_statement}"
      end

      unless self.statements.group_by.statement.length == 0
        query += " GROUP BY #{self.statements.group_by.safe_statement}"
      end

      query += " LIMIT #{self.statements.limit.safe_statement}"
    end

    def response
      @response ||= self.api.query(self.build_query)
    end

    def reload
      @response = self.api.query(self.build_query)
    end

    ############
    #Delgation to Response
    def method_missing(method, *args, &block)
      if self.response.class.instance_methods(false).include?(method) || self.response.records.class.instance_methods.include?(method)
        self.response.send(method, *args, &block)
      else
        super
      end
    end

    def inspect
      to_inspect = (self.response.try(:records) || self.response)
      to_inspect.respond_to?(:awesome_inspect) ? to_inspect.awesome_inspect : to_inspect.inspect
    end

    def dup
      the_dup = self.class.new(self.api)
      the_dup.instance_variable_set(:@statements, self.statements.dup)
      the_dup
    end

  end

end