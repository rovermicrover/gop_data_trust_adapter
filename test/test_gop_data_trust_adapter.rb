require 'minitest/autorun'
require 'gop_data_trust_adapter'

require 'awesome_print'

class GopDataTrustAdapterTest < Minitest::Unit::TestCase
  def connect
    GopDataTrustAdapter::Api.connect(:token => "ATokenPlaceHolder", :test => true)
  end

  def setup
    connect
  end

  def get_results
    @query_url = @query.response[0]
    @query_string = @query.response[1][:query]["q"]
  end

  def assert_query_contains string
    get_results
    assert_equal "https://lincoln.gopdatatrust.com/v2/api/query.php", @query_url
    assert @query_string.index(string), "Query String Doesn't Contain: " + string.to_s
  end

  ##############
  # Query TESTS
  def test_query_where
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John")
    assert_query_contains("WHERE firstname = 'John' LIMIT 5")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John", :lastname => "Smith")
    assert_query_contains("WHERE firstname = 'John' AND lastname = 'Smith' LIMIT 5")
  end

  def test_query_group_by
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname).group_by(:firstname)
    assert_query_contains("GROUP BY firstname LIMIT 5")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname).group_by(:firstname, :lastname)
    assert_query_contains("GROUP BY firstname,lastname LIMIT 5")
  end

  def test_query_or
    # Make sure that an or @query creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").or.where(:firstname => "Joan")
    assert_query_contains("WHERE firstname = 'John' OR firstname = 'Joan' LIMIT 5")
  end

  def test_query_select
    # Make sure that select creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").select("firstname")
    assert_query_contains("SELECT firstname WHERE")

    # Make sure that two select creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").select("firstname").select("lastname")
    assert_query_contains("SELECT firstname,lastname WHERE")
  end

  def test_query_count
    # Make sure that count creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").count("*")
    assert_query_contains("SELECT COUNT(*) WHERE")

    # Make sure that count and select creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").count("*").select("lastname")
    assert_query_contains("SELECT COUNT(*),lastname WHERE")

    # Make sure that two counts creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").count("firstname").count("lastname")
    assert_query_contains("SELECT COUNT(firstname),COUNT(lastname) WHERE")
  end

  def test_query_select_distinct
    # Make sure that select then distinct creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").select("firstname").distinct
    assert_query_contains("SELECT DISTINCT firstname WHERE")

    # Make sure that distinct then select creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").distinct.select("firstname")
    assert_query_contains("SELECT DISTINCT firstname WHERE")
  end

  def test_query_self_dup_return
    # Make sure parent @query isn't modified by child @query
    @query1 = GopDataTrustAdapter::Api.where(:firstname => "John")
    @query2 = @query1.where(:lastname => "Doe")
    assert !@query1.build_query.eql?(@query2.build_query)

    # Make sure two quries for same values aren't the same object,
    # but have same @query string.
    @query3 = GopDataTrustAdapter::Api.where(:firstname => "John")
    assert @query1.build_query.eql?(@query3.build_query)
    assert !@query1.object_id.eql?(@query3.object_id)
  end

  def test_sql_injection_escape
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "' OR AGE > 0 OR firstname = '")
    assert_query_contains("firstname = 'OR AGE 0 OR firstname' LIMIT 5")

    # Make sure that a @query works with non english alphabet characters.
    @query = GopDataTrustAdapter::Api.where(:firstname => "'~.,\" アあ私이~~~/';\\ñAb2ᚗ  \n\\(**&^%$#!)_+}")
    assert_query_contains("firstname = 'アあ私이ñAb2ᚗ' LIMIT 5")

    # Make sure there isn't an issue with string encoding
    value = "R\u00E9sum\u00E9".encode(Encoding::UTF_8)
    @query = GopDataTrustAdapter::Api.where(:firstname => value)
    assert_query_contains("firstname = 'Résumé' LIMIT 5")

    value = "Résumé".encode(Encoding::ISO_8859_1)
    @query = GopDataTrustAdapter::Api.where(:firstname => value)
    assert_query_contains("firstname = 'Résumé' LIMIT 5")
  end



end