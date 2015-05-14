require 'awesome_print'
require 'simplecov'
SimpleCov.start do
  add_group "Library", "lib/"
end

require 'minitest/autorun'
require 'gop_data_trust_adapter'

class GopDataTrustAdapterTest < Minitest::Test
  def connect
    GopDataTrustAdapter::Api.connect(:token => "ATokenPlaceHolder", :test => true)
  end

  def setup
    connect
  end

  def teardown
    @query = nil
    @post = nil
    @target = nil
  end

  def get_results
    if !@query.nil?
      @target = @query
      message_target = :query
    elsif !@post.nil?
      @target = @post
      message_target = :body
    end

    begin
      @target_url = @target.response[0]
      @target_hash = @target.response[1][message_target]
      @target_string = @target.response[1][message_target]["q"]
    rescue NoMethodError
      @target_url = @target[0]
      @target_hash = @target[1][message_target]
      @target_string = @target[1][message_target]["q"]
    end
  end

  def assert_url_ends_with value
    get_results
    assert @target_url.end_with?(value), "Url doesn't end with: " + value.to_s + " Instead it is: " + @target_url
  end

  def assert_query_hash_value_is_present key, value=nil
    get_results
    assert @target_hash[key]
    assert_equal(value, @target_hash[key]) if value
  end

  def assert_query_contains string, file=false
    get_results
    ends_with = (file ? "query_get_file.php" : "query.php")
    assert_url_ends_with ends_with
    assert_query_hash_value_is_present "q"
    assert @target_string.index(string), "Query String Doesn't Contain: " + string.to_s + " Instead it is: " + @target_string
  end

  def test_api_connection_urls
    GopDataTrustAdapter::Api.connect(:token => "ATokenPlaceHolder", :test => true, :production => true)
    assert_equal "https://www.gopdatatrust.com/v2/api/", GopDataTrustAdapter::Api.base_url

    GopDataTrustAdapter::Api.connect(:token => "ATokenPlaceHolder", :test => true)
    assert_equal "https://lincoln.gopdatatrust.com/v2/api/", GopDataTrustAdapter::Api.base_url
  end

  def test_api_defaults
    GopDataTrustAdapter::Api.default_token = "Foobar"
    assert_equal "Foobar", GopDataTrustAdapter::Api.default_token

    GopDataTrustAdapter::Api.default_production = true
    assert_equal true, GopDataTrustAdapter::Api.default_production?

    GopDataTrustAdapter::Api.default_production = false
    assert_equal false, GopDataTrustAdapter::Api.default_production?
  end

  # This will result in an error returned, but thats fine we just want to make sure
  # that each http method results in a successful response request not response.
  # Sleep is needed so we don't barrage them. :-/
  def test_that_http_method_is_called
    GopDataTrustAdapter::Api.connect(:token => "ATokenPlaceHolder")
    # Get
    assert GopDataTrustAdapter::Api.where(:firstname => "John").fail?
    sleep 0.2
    # Post
    assert GopDataTrustAdapter::Api.where(:firstname => "John").to_file.fail?
    sleep 0.2
    # Put
    assert GopDataTrustAdapter::Api.set_email("foobar@example.com","Foobar").fail?
    sleep 0.2
  end

  ##############
  # Query TESTS
  def test_api_to_query_delegation
    assert GopDataTrustAdapter::Api.where(:firstname => "John")

    no_method_error = false

    begin
      GopDataTrustAdapter::Api.foobar
    rescue NoMethodError
      no_method_error = true
    end

    assert no_method_error
  end

  def test_query_to_response_delegation
    @query = GopDataTrustAdapter::Api.where(:firstname => "John")

    assert @query.length

    no_method_error = false

    begin
      @query.foobar
    rescue NoMethodError
      no_method_error = true
    end

    assert no_method_error
  end

  def test_query_inspect
    assert GopDataTrustAdapter::Api.where(:firstname => "John").inspect
  end

  def test_query_where
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John")
    assert_query_contains("WHERE firstname = 'John' LIMIT 5")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John", :lastname => "Smith")
    assert_query_contains("WHERE firstname = 'John' AND lastname = 'Smith' LIMIT 5")
  end

  def test_query_where_of_non_standard_object
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where("firstname = ?", Object.new)
    assert_query_contains("WHERE firstname = 'Object:")
  end

  def test_query_group_by
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname).group_by(:firstname)
    assert_query_contains("GROUP BY firstname LIMIT 5")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname).group_by(:firstname, :lastname)
    assert_query_contains("GROUP BY firstname,lastname LIMIT 5")
  end

  def test_query_count
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname).group_by(:firstname)
    assert_query_contains("SELECT COUNT(firstname)")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname, :lastname).group_by(:firstname)
    assert_query_contains("SELECT COUNT(firstname),COUNT(lastname)")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.select(:firstname).count(:firstname, :lastname).group_by(:firstname)
    assert_query_contains("SELECT firstname,COUNT(firstname),COUNT(lastname)")

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.count(:firstname, :lastname).select(:firstname).group_by(:firstname)
    assert_query_contains("SELECT COUNT(firstname),COUNT(lastname),firstname")
  end

  def test_query_or
    # Make sure that an or @query creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").or.where(:firstname => "Joan")
    assert_query_contains("WHERE firstname = 'John' OR firstname = 'Joan' LIMIT 5")
  end

  def test_query_limit
    # Make sure that an or @query creates the correct sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").limit(10)
    assert_query_contains("WHERE firstname = 'John' LIMIT 10")
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

  def test_query_reload
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John")
    assert_query_contains("WHERE firstname = 'John' LIMIT 5")

    @query.reload
    assert_query_contains("WHERE firstname = 'John' LIMIT 5")
  end

  def test_sql_injection_escape
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "' OR AGE > 0 OR firstname = '")
    assert_query_contains("firstname = 'OR AGE 0 OR firstname' LIMIT 5")

    # Make sure that a @query works with non english alphabet characters.
    @query = GopDataTrustAdapter::Api.where(:firstname => "'~.,\" -:アあ私이~~~/';\\ñAb2ᚗ @ \n\\(**&^%$#!)_+}")
    assert_query_contains("firstname = '. -:アあ私이ñAb2ᚗ @' LIMIT 5")

    # Make sure there isn't an issue with string encoding
    value = "R\u00E9sum\u00E9".encode(Encoding::UTF_8)
    @query = GopDataTrustAdapter::Api.where(:firstname => value)
    assert_query_contains("firstname = 'Résumé' LIMIT 5")

    value = "Résumé".encode(Encoding::ISO_8859_1)
    @query = GopDataTrustAdapter::Api.where(:firstname => value)
    assert_query_contains("firstname = 'Résumé' LIMIT 5")
  end

  def test_query_number
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:age => "5")
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:age => 5)
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:age => 5.0)
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:age => BigDecimal.new("5.0"))
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("age = ?", 5)
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("age = ?", 5.0)
    assert_query_contains("WHERE age = 5 LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("age = ?", BigDecimal.new("5.0"))
    assert_query_contains("WHERE age = 5 LIMIT 5")
  end

  def test_query_date
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => '2001-02-03')
    assert_query_contains("WHERE ah_rowcreatedate = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => Date.new(2001,2,3))
    assert_query_contains("WHERE ah_rowcreatedate = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => DateTime.new(2001,2,3))
    assert_query_contains("WHERE ah_rowcreatedate = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => Time.new(2001,2,3))
    assert_query_contains("WHERE ah_rowcreatedate = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => 628232400)
    assert_query_contains("WHERE ah_rowcreatedate = '1989-11-27' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => 628232400.0)
    assert_query_contains("WHERE ah_rowcreatedate = '1989-11-27' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate =>  BigDecimal.new("628232400.0"))
    assert_query_contains("WHERE ah_rowcreatedate = '1989-11-27' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:dateofbirth => '2001-02-03')
    assert_query_contains("WHERE dateofbirth = '20010203' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("ah_rowcreatedate = ?",  Date.new(2001,2,3))
    assert_query_contains("WHERE ah_rowcreatedate = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("dateofbirth = ?",  [Date.new(2001,2,3), :no_dash])
    assert_query_contains("WHERE dateofbirth = '20010203' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("dateofbirth = ?",  {:value => Date.new(2001,2,3), :format => :no_dash})
    assert_query_contains("WHERE dateofbirth = '20010203' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("ah_rowcreatedatetime = ?",  '2001-02-03')
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedate => Object.new)
    assert_query_contains("WHERE ah_rowcreatedate = '" + DateTime.now.strftime("%Y-%m-%d"))
  end

  def test_query_datetime
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => '2001-02-03 11:24:34.100')
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 11:24:34.100' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => Date.new(2001,2,3))
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 00:00:00.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => DateTime.new(2001,2,3,11,24,34))
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 11:24:34.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => Time.new(2001,2,3,11,24,34))
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 11:24:34.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => 2451944)
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 00:00:00.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => 2451944.0)
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 00:00:00.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime =>  BigDecimal.new("2451944.0"))
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 00:00:00.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("ah_rowcreatedatetime = ?",  DateTime.new(2001,2,3,11,24,34))
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 11:24:34.000' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where("ah_rowcreatedatetime = ?",  '2001-02-03 11:24:34.100')
    assert_query_contains("WHERE ah_rowcreatedatetime = '2001-02-03 11:24:34.100' LIMIT 5")

    @query = GopDataTrustAdapter::Api.where(:ah_rowcreatedatetime => Object.new)
    assert_query_contains("WHERE ah_rowcreatedatetime = '" + DateTime.now.strftime("%Y-%m-%d"))
  end
  ##############

  ##############
  # Response TESTS
  #
  # These are all real response form the DataTrust
  SUCCESSFUL_RESPONSE = OpenStruct.new(:body => '{"Call_ID":"5553bd04634816da4403d4e8","Success":true,"Results":[{"firstname":"RUTH"},{"firstname":"LESLIE"},{"firstname":"DAVID"},{"firstname":"GEORGE"},{"firstname":"LIONEL"}],"Results_Count":5,"More_Results":false}')
  UNSUCCESSFUL_RESPONSE = OpenStruct.new(:body => '{"Call_ID":"5553bc77634816d44403d4e7","Success":false,"Error":"Unparseable DQL statement! Take a look at examples at https:\/\/lincoln.gopdatatrust.com\/v2\/docs\/"}')
  INTERNAL_ERROR_RESPONSE= OpenStruct.new(:body => '{"Call_ID":"5553be65634816d44403d4e8","Success":false,"Error":"Internal read error."}')

  def assert_debug_succesful call_id
    @debug = @response.debug
    assert @debug
    assert @debug[0].end_with?("get_call.php")
    assert @debug[1][:query]["Call_ID"]
    assert_equal call_id, @debug[1][:query]["Call_ID"]
  end

  def test_response_success
    @response = GopDataTrustAdapter::Response.new(GopDataTrustAdapter::Api, SUCCESSFUL_RESPONSE)
    assert @response.success?, "was not considered succesful"
    assert !@response.fail?, "was considered failure"

    assert @response.to_a.length > 0, "no records found when called by delgated method"
    assert @response.records.length > 0, "no records found when called by accesor method"

    @debug = @response.debug
    assert @debug.nil?
  end

  def test_response_unsuccess
    @response = GopDataTrustAdapter::Response.new(GopDataTrustAdapter::Api, UNSUCCESSFUL_RESPONSE)
    assert !@response.success?, "was considered succesful"
    assert @response.fail?, "was not considered failure"

    assert_debug_succesful "5553bc77634816d44403d4e7"
  end

  def test_response_internal_error
    @response = GopDataTrustAdapter::Response.new(GopDataTrustAdapter::Api, INTERNAL_ERROR_RESPONSE)
    assert !@response.success?, "was considered succesful"
    assert @response.fail?, "was not considered failure"

    assert_debug_succesful "5553be65634816d44403d4e8"
  end

  def test_response_to_results_delgation
    @response = GopDataTrustAdapter::Response.new(GopDataTrustAdapter::Api, SUCCESSFUL_RESPONSE)

    assert @response.length

    no_method_error = false
    begin
      @response.foobar
    rescue NoMethodError
      no_method_error = true
    end
    assert no_method_error
  end
  ##############

  ##############
  # Records TESTS
  #
  # This is a real response form the DataTrust
  SUCCESSFUL_RESPONSE_RECORDS = OpenStruct.new(:body => '{"Call_ID":"5553bd04634816da4403d4e8","Success":true,"Results":[{"firstname":"RUTH","lastname":"WISSER"},{"firstname":"LESLIE","lastname":"REYES"},{"firstname":"DAVID","lastname":"PARKER"},{"firstname":"GEORGE","lastname":"KNITTEL"},{"firstname":"LIONEL","lastname":"PONX"}],"Results_Count":5,"More_Results":false}')

  def test_response_success
    @response = GopDataTrustAdapter::Response.new(GopDataTrustAdapter::Api, SUCCESSFUL_RESPONSE_RECORDS)

    @record = @response.records[0]

    assert @record.is_a? GopDataTrustAdapter::Record
    assert_equal "RUTH", @record.firstname
    assert_equal "WISSER", @record.lastname
    assert_equal nil, @record.age

    no_method_error = false

    begin
      @record.foobar
    rescue NoMethodError
      no_method_error = true
    end

    assert no_method_error
  end
  ##############

  ##############
  # Fast Match TESTS
  def test_fast_match
    @query = GopDataTrustAdapter::Api.fast_match(
      :firstname => "John",
      :firs_tname => "Albert",
      :middle_name => "James",
      :last_name => "Smith",
      :dateofbirth => Date.new(1989,2,19),
      :zip => "78701",
      :limit => 4
    )
    assert_query_hash_value_is_present "FirstName", "John"
    assert_query_hash_value_is_present "MiddleName", "James"
    assert_query_hash_value_is_present "LastName", "Smith"
    assert_query_hash_value_is_present "DateOfBirth", "19890219"
    assert_query_hash_value_is_present "Reg_AddressZip5", "78701"
    assert_query_hash_value_is_present "Limit", "4"
  end
  ##############

  ##############
  # Get File TESTS
  def test_to_file
    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John").to_file
    assert_query_contains("WHERE firstname = 'John' LIMIT 5", true)

    # Make sure that a @query for a attribute creates the create sql
    @query = GopDataTrustAdapter::Api.where(:firstname => "John", :lastname => "Smith").to_file
    assert_query_contains("WHERE firstname = 'John' AND lastname = 'Smith' LIMIT 5", true)
  end
  ##############
  ##############

  ##############
  # Write Methods

  ##############
  # Post Tags TESTS
  def test_add_tag
    @post = GopDataTrustAdapter::Api.add_tag(
      "Foobar",
      :year => 2005,
      :name => "Something",
      :desc => "A desc of something."
    )
    assert_query_hash_value_is_present "PersonKey", "Foobar"
    assert_query_hash_value_is_present "ElementYear", "2005"
    assert_query_hash_value_is_present "ElementName", "Something"
    assert_query_hash_value_is_present "ElementDescription", "A desc of something."
  end
  ##############

  ##############
  # Post Tags TESTS
  def test_add_voter_contact
    @post = GopDataTrustAdapter::Api.add_voter_contact(
      "AType",
      "Foobar",
      :type => "Man on the street",
      :disposition => "Happy",
      :datetime => DateTime.new(2001,2,3,11,24,34),
      :state_abbreviation => "TX",
      :office_name => "Texas Senate",
      :initiative_name => "JoJo",
      :universe_name => "Milky Way"
    )
    assert_query_hash_value_is_present "AType", "Foobar"
    assert_query_hash_value_is_present "ContactType", "Man on the street"
    assert_query_hash_value_is_present "ContactDisposition", "Happy"
    assert_query_hash_value_is_present "StateAbbreviation", "TX"
    assert_query_hash_value_is_present "OfficeName", "Texas Senate"
    assert_query_hash_value_is_present "InitiativeName", "JoJo"
    assert_query_hash_value_is_present "UniverseName", "Milky Way"
    assert_query_hash_value_is_present "ContactDate", "2001-02-03"
    assert_query_hash_value_is_present "ContactTime", "11:24:34"
  end
  ##############

  ##############
  # Put Email TESTS
  def test_set_email
    @query = GopDataTrustAdapter::Api.set_email(
      "foobar@example.com",
      "Foobar"
    )
    assert_query_hash_value_is_present "EmailAddress", "foobar@example.com"
    assert_query_hash_value_is_present "PersonKey", "Foobar"
  end
  ##############

  ##############
  # Put Phone TESTS
  def test_set_phone
    @query = GopDataTrustAdapter::Api.set_phone(
      "512 555 5555",
      "Foobar"
    )
    assert_query_hash_value_is_present "PhoneNumber", "512 555 5555"
    assert_query_hash_value_is_present "PersonKey", "Foobar"
  end
  ##############

  ##############
  # Put Address TESTS
  def test_set_address
    @query = GopDataTrustAdapter::Api.set_address(
      "AType",
      "Foobar",
      :address_1 => "1609 Shoak Creek",
      :address_2 => "Suite 203",
      :city => "Austin",
      :state => "TX",
      :zip5 => "78701",
      :zip4 => "1111"
    )
    assert_query_hash_value_is_present "AddressType", "AType"
    assert_query_hash_value_is_present "VoterKey", "Foobar"
    assert_query_hash_value_is_present "AddressLine1", "1609 Shoak Creek"
    assert_query_hash_value_is_present "AddressLine2", "Suite 203"
    assert_query_hash_value_is_present "AddressCity", "Austin"
    assert_query_hash_value_is_present "AddressState", "TX"
    assert_query_hash_value_is_present "AddressZip5", "78701"
    assert_query_hash_value_is_present "AddressZip4", "1111"
  end
  ##############

  ##############
  # Put Direct Write TESTS
  def test_direct_write
    @query = GopDataTrustAdapter::Api.direct_write(
      "AnAction",
      "Afield",
      :call_id => "171831",
      :pk_id => "287561",
      :values => {:some => "thing", :to => "update", :width => "."},
      :leave_open => false,
      :rationale => "My rationale..."
    )
    assert_query_hash_value_is_present "Action", "AnAction"
    assert_query_hash_value_is_present "PK_Field", "Afield"
    assert_query_hash_value_is_present "Call_ID", "171831"
    assert_query_hash_value_is_present "pk_id", "287561"
    assert_query_hash_value_is_present "Values", "{\"some\":\"thing\",\"to\":\"update\",\"width\":\".\"}"
    assert_query_hash_value_is_present "Leave_Open", "false"
    assert_query_hash_value_is_present "Rationale", "My rationale..."
  end
  ##############



end