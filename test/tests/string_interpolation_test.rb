class StringInterpolationTest < Test::Unit::TestCase
  
  def setup
    @country1 = Country.create(:name => 'United Kingdom', :currency => 'GBP')
    @country2 = Country.create(:name => 'Germany', :currency => 'EUR')
    @user1 = User.create(:first_name => 'Joe', :last_name => 'Bloggs', :age => 40, :fruit => 'Apple', :country => @country1, :date_of_birth => Date.parse("1960-10-23"), :time_of_birth => Time.parse('14:52:10'))
    @user2 = User.create(:first_name => 'Sarah', :last_name => 'Smith', :age => 26, :fruit => 'Bananas', :country => @country2, :date_of_birth => Date.parse("1986-11-08"), :time_of_birth => Time.parse('05:30:00'))
  end
  
  def test_basic_strings
    assert_equal "United Kingdom", Florrick.convert('{{country.name}}', :country => @country1)
    assert_equal "United Kingdom!", Florrick.convert('{{country.name}}!', :country => @country1)
    assert_equal "Joe is 40", Florrick.convert("{{user.first_name}} is {{user.age}}", :user => @user1)
  end
  
  def test_relationships
    assert_equal "Sarah from Germany", Florrick.convert("{{user.first_name}} from {{user.country.name}}", :user => @user2)
  end
  
  def test_custom_strings
    assert_equal "Joe Bloggs", Florrick.convert("{{user.full_name}}", :user => @user1)
  end
  
  def test_multiple_objects
    assert_equal "Joe Germany", Florrick.convert("{{user.first_name}} {{country.name}}", :user => @user1, :country => @country2)
  end
  
  def test_nil_processing
    assert_equal "", Florrick.convert("{{user.place_of_birth}}", :user => @user1)
    assert_equal "", Florrick.convert("{{user.place_of_birth.downcase}}", :user => @user1)
  end
  
  def test_invalid_objects
    assert_equal "{{blah.name}}", Florrick.convert("{{blah.name}}")
    assert_equal "{{user}}", Florrick.convert("{{user}}", :user => @user1)
    assert_equal "{{user.non_existant}}", Florrick.convert("{{user.non_existant}}", :user => @user1)
    assert_equal "{{user.fruit}}", Florrick.convert("{{user.fruit}}", :user => @user1)
  end
  
  def test_builtin_string_formatting
    assert_equal "joe", Florrick.convert("{{user.first_name.downcase}}", :user => @user1)
    assert_equal "JOE", Florrick.convert("{{user.first_name.upcase}}", :user => @user1)
    assert_equal "Joe", Florrick.convert("{{user.first_name.downcase.humanize}}", :user => @user1)
    assert_equal "89661149f1b62ff47dd5a6fe4f979c9f53f619b6", Florrick.convert("{{user.first_name.sha1}}", :user => @user1)
    assert_equal "3a368818b7341d48660e8dd6c5a77dbe", Florrick.convert("{{user.first_name.md5}}", :user => @user1)

  end
  
  def test_builtin_numeric_formatting
    assert_equal "80", Florrick.convert("{{user.age.double}}", :user => @user1)
    assert_equal "120", Florrick.convert("{{user.age.triple}}", :user => @user1)
  end
  
  def test_builtin_date_formatting
    assert_equal "Sunday 23rd October 1960", Florrick.convert("{{user.date_of_birth.long_date}}", :user => @user1)
    assert_equal "23rd October 1960", Florrick.convert("{{user.date_of_birth.long_date_without_day_name}}", :user => @user1)
    assert_equal "Sun 23 Oct 1960", Florrick.convert("{{user.date_of_birth.short_date}}", :user => @user1)
    assert_equal "23 Oct 1960", Florrick.convert("{{user.date_of_birth.short_date_without_day_name}}", :user => @user1)
    
    assert_equal "23/10/1960", Florrick.convert("{{user.date_of_birth.ddmmyyyy}}", :user => @user1)
    assert_equal "14:52", Florrick.convert("{{user.time_of_birth.hhmm}}", :user => @user1)
    assert_equal "14:52:10", Florrick.convert("{{user.time_of_birth.hhmmss}}", :user => @user1)
    assert_equal "02:52pm", Florrick.convert("{{user.time_of_birth.hhmm12}}", :user => @user1)
    assert_equal "02:52:10pm", Florrick.convert("{{user.time_of_birth.hhmmss12}}", :user => @user1)
    assert_equal "02:52PM", Florrick.convert("{{user.time_of_birth.hhmm12.upcase}}", :user => @user1)
  end
  
  def test_custom_formatting
    Florrick::Formatter.add 'add5', [Numeric] do |value|
      value +5
    end
    assert_equal "{{user.age.invalid_formatter}}", Florrick.convert("{{user.age.invalid_formatter}}", :user => @user1)
    assert_equal "45", Florrick.convert("{{user.age.add5}}", :user => @user1)
    assert_equal "50", Florrick.convert("{{user.age.add5.add5}}", :user => @user1)
    assert_equal "{{user.first_name.add5}}", Florrick.convert("{{user.first_name.add5}}", :user => @user1)
  end
  
  def test_catching_errors_in_formatters
    Florrick::Formatter.add 'divideby0', [Numeric] do |value|
      value / 0
    end
    assert_equal "???", Florrick.convert("{{user.age.divideby0}}", :user => @user1)
  end
  
end