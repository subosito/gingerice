require 'optparse'
require 'awesome_print'
require 'gingerice/parser'
require 'gingerice/version'

module Gingerice
  class Command

    attr_reader :args, :oparser

    def initialize(args)
      @args = args
    end

    def processor
      options = {}
      options[:api_endpoint] = Gingerice::Parser::GINGER_ENDPOINT
      options[:api_version] = Gingerice::Parser::GINGER_VERSION
      options[:api_key] = Gingerice::Parser::GINGER_API_KEY
      options[:lang] = Gingerice::Parser::DEFAULT_LANG
      options[:verbose] = false

      @oparser = OptionParser.new do |opt|
        opt.banner = 'Usage: gingerice [options] "some texts"'

        opt.on("--api-endpoint API_ENDPOINT", "Set API endpoint") do |endpoint|
          options[:api_endpoint] = endpoint
        end

        opt.on("--api-version API_VERSION", "Set API version") do |version|
          options[:api_endpoint] = version
        end

        opt.on("--api-key API_KEY", "Set API key") do |api_key|
          options[:api_key] = api_key
        end

        opt.on("--lang LANG", "Set language, currently support 'US' only") do |lang|
          options[:lang] = lang
        end

        opt.on("-v", "--verbose", "Verbose output") do
          options[:verbose] = true
        end

        opt.on("--version", "Show version") do
          puts Gingerice::VERSION
          exit
        end

        opt.on_tail("-h", "--help", "Show this message") do
          puts opt
          exit
        end
      end

      @oparser.parse!(args)
      options
    end

    def execute
      options = processor

      if args.empty?
        puts oparser
      else
        parser_options = options.reject { |key, value| key == :verbose }

        parser   = Parser.new(parser_options)
        response = parser.parse(args.last)

        if options[:verbose]
          ap response
        else
          puts response["result"]
        end
      end
    end
  end
end

