require 'open-uri'
require 'addressable/uri'
require 'json'

module Gingerice
  class Parser
    GINGER_API_ENDPOINT = 'http://services.gingersoftware.com/Ginger/correct/json/GingerTheText'
    GINGER_API_VERSION  = '2.0'
    GINGER_API_KEY      = '6ae0c3a0-afdc-4532-a810-82ded0054236'
    DEFAULT_LANG        = 'US'

    attr_accessor :lang, :api_key, :api_version, :api_endpoint

    def initialize(options = {})
      merge_options(options).each do |key, value|
        send("#{key}=", value)
      end
    end

    def parse(text)
      uri = Addressable::URI.parse(api_endpoint)
      uri.query_values = request_params.merge({ 'text' => text })

      begin
        open(uri) do |stream|
          response_processor(text, stream.read)
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end

    def self.default_options
      {
        :api_endpoint => Gingerice::Parser::GINGER_API_ENDPOINT,
        :api_version  => Gingerice::Parser::GINGER_API_VERSION,
        :api_key      => Gingerice::Parser::GINGER_API_KEY,
        :lang         => Gingerice::Parser::DEFAULT_LANG
      }
    end

    protected
    def merge_options(options)
      options.select! do |key, _|
        Parser.default_options.include?(key)
      end

      Parser.default_options.merge(options)
    end

    def response_processor(text, content)
      data = JSON.parse(content)
      i = 0
      result = ''
      corrections = []

      data.fetch('LightGingerTheTextResult', []).each do |r|
        from = r['From']
        to   = r['To']

        if i <= from
          result += text[i..from-1] unless from.zero?
          result += r['Suggestions'][0]['Text']

          definition = r['Suggestions'][0]['Definition']

          if definition.respond_to? :empty?
            definition = nil if definition.empty?
          end

          corrections << {
            'text'       => text[from..to],
            'correct'    => r['Suggestions'][0]['Text'],
            'definition' => definition,
            'start'      => from,
            'length'     => to.to_i - from.to_i + 1
          }
        end

        i = to+1
      end

      if i < text.length
        result += text[i..-1]
      end

      { 'text' => text, 'result' => result, 'corrections' => corrections}
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

