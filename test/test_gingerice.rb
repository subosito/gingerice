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
require 'gingerice'
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

  def test_command_simple_output
    output = capture_stdout do
      command = Gingerice::Command.new(["Edwards will be sck yesterday"])
      command.execute
    end
    assert_equal "Edwards was sick yesterday\n", output.string
  end

  def test_command_verbose_output
    output = capture_stdout do
      command = Gingerice::Command.new(["-v", "He flyed to Jakarta"])
      command.execute
    end
    assert_match 'corrections', output.string
  end

  def test_command_help_usage
    output = capture_stdout do
      command = Gingerice::Command.new([])
      command.execute
    end
    assert_match "Usage:", output.string
  end

  def test_command_show_version
    output = capture_stdout do
      command = Gingerice::Command.new(['--version'])
      command.execute
    end
    assert_equal "Gingerice: #{Gingerice::VERSION}\n", output.string
  end

  def test_command_arg_api_endpoint
    command = Gingerice::Command.new(['--api-endpoint', 'http://example.id/'])
    options = command.options

    assert_equal "http://example.id/", options[:api_endpoint]
  end

  def test_command_arg_api_version
    command = Gingerice::Command.new(['--api-version', '1.0'])
    options = command.options

    assert_equal "1.0", options[:api_version]
  end

  def test_command_arg_api_key
    command = Gingerice::Command.new(['--api-key', '123456'])
    options = command.options

    assert_equal "123456", options[:api_key]
  end

  def test_command_arg_lang
    command = Gingerice::Command.new(['--lang', 'ID'])
    options = command.options

    assert_equal "ID", options[:lang]
  end

  def test_request_exceptions
    exception = assert_raise(Gingerice::ConnectionError) { @custom_parser.parse('Hllo') }
    assert_equal "ERROR: Couldn't connect to API endpoint (http://example.id/)", exception.message
  end

  def test_parse_error_exceptions
    invalid_parser = Gingerice::Parser.new({
      api_endpoint: 'http://subosito.com/',
    })

    exception = assert_raise(Gingerice::ParseError) { invalid_parser.parse('Hllo') }
    assert_equal 'ERROR: We receive invalid JSON format!', exception.message
  end
end

