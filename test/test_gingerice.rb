require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'gingerice'

class TestGingerice < Test::Unit::TestCase
  def setup
    @parser = Gingerice::Parser.new
    @custom_parser = Gingerice::Parser.new({
      lang: 'ID',
      api_endpoint: 'http://example.id/',
      api_version: '1.0',
      api_key: '123456'
    })
  end

  def test_default_settings
    assert_equal @parser.api_endpoint, Gingerice::Parser::GINGER_ENDPOINT
    assert_equal @parser.api_version, Gingerice::Parser::GINGER_VERSION
    assert_equal @parser.api_key, Gingerice::Parser::GINGER_API_KEY
    assert_equal @parser.lang, Gingerice::Parser::DEFAULT_LANG
  end

  def test_override_settings
    assert_equal @custom_parser.lang, 'ID'
    assert_equal @custom_parser.api_endpoint, 'http://example.id/'
    assert_equal @custom_parser.api_version, '1.0'
    assert_equal @custom_parser.api_key, '123456'
  end

  def test_parsed_results
    text   = 'The smelt of fliwers bring back memories.'
    result = @parser.parse(text)

    assert_equal result['text'], text
    assert_equal result['result'], 'The smell of flowers brings back memories.'
    assert_equal result['corrections'].count, 3
  end

  def test_exceptions
    exception = assert_raise(StandardError) { @custom_parser.parse('Hllo') }
    assert_equal exception.message, 'getaddrinfo: Name or service not known'
  end
end
