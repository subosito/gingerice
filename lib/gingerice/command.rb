require 'optparse'
require 'awesome_print'
require 'gingerice'

module Gingerice
  class Command

    attr_reader :args, :args_parser, :options

    def initialize(args)
      @args = args
      @args << '-h' if @args.empty?

      @options     = Gingerice::Parser.default_options.merge({ :output => :simple })
      @args_parser = parse_args
    end

    def execute
      if options.has_key?(:show)

        case options[:show]
        when :help
          puts args_parser
        when :version
          puts "Gingerice: #{Gingerice::VERSION}"
        end

      else
        parser_opts = options.select { |k, _| Parser.default_options.keys.include?(k) }
        parser      = Parser.new(parser_opts)
        response    = parser.parse(args.last)

        if options[:output] === :verbose
          ap response
        else
          puts response
        end
      end
    end

    protected
    def parse_args
      OptionParser.new do |opt|
        opt.banner = 'Usage: gingerice [options] "some texts"'

        opt.on("--api-endpoint API_ENDPOINT", "Set API endpoint") do |endpoint|
          options[:api_endpoint] = endpoint
        end

        opt.on("--api-version API_VERSION", "Set API version") do |version|
          options[:api_version] = version
        end

        opt.on("--api-key API_KEY", "Set API key") do |api_key|
          options[:api_key] = api_key
        end

        opt.on("--lang LANG", "Set language, currently support 'US' only") do |lang|
          options[:lang] = lang
        end

        opt.on("-v", "--verbose", "Verbose output (deprecated: use --output verbose, instead)") do
          options[:output] = :verbose
        end

        opt.on("-o", "--output OUTPUT", "Output type") do |output|
          case output
          when 'verbose'
            options[:output] = :verbose
          when 'count'
            options[:output] = :count
          else
            options[:output] = :simple
          end
        end

        opt.on("--version", "Show version") do
          options[:show] = :version
        end

        opt.on_tail("-h", "--help", "Show this message") do
          options[:show] = :help
        end

        opt.parse!(args)
      end
    end
  end
end

