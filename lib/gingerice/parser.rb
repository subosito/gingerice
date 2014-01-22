require 'open-uri'
require 'addressable/uri'
require 'json'
require 'gingerice/version'
require 'gingerice/error'

module Gingerice
  class Parser
    GINGER_API_ENDPOINT = 'http://services.gingersoftware.com/Ginger/correct/json/GingerTheText'
    GINGER_API_VERSION  = '2.0'
    GINGER_API_KEY      = '6ae0c3a0-afdc-4532-a810-82ded0054236'
    DEFAULT_LANG        = 'US'

    attr_accessor :lang, :api_key, :api_version, :api_endpoint
    attr_reader   :text, :raw_response, :result

    def initialize(options = {})
      merge_options(options).each do |key, value|
        send("#{key}=", value)
      end

      @result      = ''
      @corrections = []
    end

    def parse(text)
      @text = text
      perform_request
      process_response
    end

    def self.default_options
      {
        :api_endpoint => GINGER_API_ENDPOINT,
        :api_version  => GINGER_API_VERSION,
        :api_key      => GINGER_API_KEY,
        :lang         => DEFAULT_LANG
      }
    end

    protected
    def merge_options(options)
      options.select! do |key, _|
        Parser.default_options.include?(key)
      end

      Parser.default_options.merge(options)
    end

    def perform_request
      uri = Addressable::URI.parse(api_endpoint)
      uri.query_values = request_params.merge({ 'text' => text })

      begin
        open(uri) do |stream|
          @raw_response = stream.read
        end
      rescue Exception => _
        raise ConnectionError, "ERROR: Couldn't connect to API endpoint (#{api_endpoint})"
      end
    end

    def process_response
      begin
        json_data = JSON.parse(raw_response)

        i = 0

        json_data.fetch('LightGingerTheTextResult', []).each do |data|
          process_suggestions(i, data)

          i = data['To']+1
        end

        if i < text.length
          @result += text[i..-1]
        end

        {
          'text'        => text,
          'result'      => result,
          'corrections' => @corrections
        }
      rescue Exception => _
        raise ParseError, "ERROR: We receive invalid JSON format!"
      end
    end

    def process_suggestions(i, data)
      from = data['From']
      to   = data['To']

      if i <= from
        @result   += text[i..from-1] unless from.zero?
        suggestion = data['Suggestions'].first

        if suggestion
          suggestion_text = suggestion['Text']
          @result += suggestion_text

          definition = suggestion['Definition']
          definition = nil if definition.respond_to?(:empty?) && definition.empty?

          @corrections << {
            'text'       => text[from..to],
            'correct'    => suggestion_text,
            'definition' => definition,
            'start'      => from,
            'length'     => to - from + 1
          }
        end
      end
    end

    def request_params
      {
        'lang'          => lang,
        'apiKey'        => api_key,
        'clientVersion' => api_version
      }
    end
  end
end

