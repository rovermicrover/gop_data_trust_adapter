require 'gop_data_trust_adapter/statement/base'

require 'gop_data_trust_adapter/statement/select'
require 'gop_data_trust_adapter/statement/where'
require 'gop_data_trust_adapter/statement/group_by'
require 'gop_data_trust_adapter/statement/limit'

module GopDataTrustAdapter

  ##
  #
  # Class that handles all the statements for a given query

  class Statements

    attr_reader :select, :where, :group_by, :limit, :query

    def initialize _query
      @query = _query
      @select = Statement::Select.new(self)
      @where = Statement::Where.new(self)
      @group_by = Statement::GroupBy.new(self)
      @limit = Statement::Limit.new(self)
    end

    ##
    #
    # Dup each statement and then return new statements collection
    # object.

    def dup
      the_dup = self.class.new(self.query)
      the_dup.instance_variable_set(:@select, self.select.dup)
      the_dup.instance_variable_set(:@where, self.where.dup)
      the_dup.instance_variable_set(:@group_by, self.group_by.dup)
      the_dup.instance_variable_set(:@limit, self.limit.dup)
      the_dup
    end

  end

end