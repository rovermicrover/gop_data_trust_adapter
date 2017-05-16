require 'gop_data_trust_adapter/statements'

module GopDataTrustAdapter


  ##
  #
  # Class that handles the actually building of the quries

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
      the_dup.statements.select.add_select(*columns)
      the_dup
    end

    def count *columns
      the_dup = self.dup
      the_dup.statements.select.add_count(*columns)
      the_dup
    end

    def group_by *columns
      the_dup = self.dup
      the_dup.statements.group_by.add_grouping(*columns)
      the_dup
    end

    def limit _limit
      the_dup = self.dup
      the_dup.statements.limit.set_limit _limit
      the_dup
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

    def request
      @request ||= self.api.query(self.build_query)
    end

    def reload
      @request = self.api.query(self.build_query)
    end

    def file_request *emails
      self.api.get_file(self.build_query, *emails)
    end

    def to_file *emails
      self.file_request(*emails).get_response
    end

    ##
    #
    #Delgation to Response through request

    def method_missing(method_name, *args, &block)
      if Response.instance_methods(false).include?(method_name) || Array.instance_methods(false).include?(method_name)
        self.request.send(method_name, *args, &block)
      else
        super
      end
    end

    ##
    #
    #Make sure respond_to? includes deleged methods

    def respond_to_missing?(method_name, include_private = false)
      Response.instance_methods(false).include?(method_name) || Array.instance_methods(false).include?(method_name) || super
    end

    def inspect
      request.inspect
    end

    def dup
      the_dup = self.class.new(self.api)
      the_dup.instance_variable_set(:@statements, self.statements.dup)
      the_dup
    end

  end

end