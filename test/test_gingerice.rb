require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

require 'stringio'
module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end

require 'test/unit'
require 'gingerice/parser'
require 'gingerice/command'

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
    assert_equal Gingerice::Parser::GINGER_API_ENDPOINT, @parser.api_endpoint
    assert_equal Gingerice::Parser::GINGER_API_VERSION, @parser.api_version
    assert_equal Gingerice::Parser::GINGER_API_KEY, @parser.api_key
    assert_equal Gingerice::Parser::DEFAULT_LANG, @parser.lang
  end

  def test_override_settings
    assert_equal 'ID', @custom_parser.lang
    assert_equal 'http://example.id/', @custom_parser.api_endpoint
    assert_equal '1.0', @custom_parser.api_version
    assert_equal '123456', @custom_parser.api_key
  end

  def test_parsed_results
    text   = 'The smelt of fliwers bring back memories.'
    result = @parser.parse(text)

    assert_equal text, result['text']
    assert_equal 'The smell of flowers brings back memories.', result['result']
    assert_equal 3, result['corrections'].count
    assert_equal 4, result['corrections'].first['start']
    assert_equal 5, result['corrections'].first['length']
  end

  def test_exceptions
    exception = assert_raise(StandardError) { @custom_parser.parse('Hllo') }
    assert_equal 'getaddrinfo: Name or service not known', exception.message
  end

  def test_command_usage
    output = capture_stdout do
      command = Gingerice::Command.new(["Edwards will be sck yesterday"])
      command.execute
    end
    assert_equal "Edwards was sick yesterday\n", output.string
  end

  def test_command_help
    output = capture_stdout do
      command = Gingerice::Command.new([])
      command.execute
    end
    assert_match "Usage:", output.string
  end
end

