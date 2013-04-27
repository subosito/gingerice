require 'open-uri'
require 'addressable/uri'
require 'json'

module Gingerice
  class Parser
    GINGER_ENDPOINT = 'http://services.gingersoftware.com/Ginger/correct/json/GingerTheText'
    GINGER_VERSION  = '2.0'
    GINGER_API_KEY  = '6ae0c3a0-afdc-4532-a810-82ded0054236'
    DEFAULT_LANG    = 'US'

    attr_reader :lang, :api_key, :api_version, :api_endpoint

    def initialize(lang = DEFAULT_LANG, api_key = GINGER_API_KEY, api_version = GINGER_VERSION, api_endpoint = GINGER_ENDPOINT)
      @lang = lang
      @api_key = api_key
      @api_version = api_version
      @api_endpoint = api_endpoint
    end

    def parse(text)
      uri = Addressable::URI.parse(@api_endpoint)
      uri.query_values = request_params.merge({ 'text' => text })

      begin
        open(uri) do |stream|
          content = stream.read
          data    = JSON.parse(content)

          i = 0
          result = ''
          corrections = []

          data.fetch('LightGingerTheTextResult', []).each do |r|
            from = r['From']
            to   = r['To']

            if i <= from
              result += text[i..from-1] unless from.zero?
              result += r['Suggestions'][0]['Text']

              corrections << {
                'text'       => text[from..to],
                'correct'    => r['Suggestions'][0]['Text'],
                'definition' => r['Suggestions'][0]['Definition']
              }
            end

            i = to+1
          end

          if i < text.length
            result += text[i..-1]
          end

          { 'text' => text, 'result' => result, 'corrections' => corrections}
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end

    protected
    def request_params
      {
        'lang' => @lang,
        'apiKey' => @api_key,
        'clientVersion' => @api_version
      }
    end
  end
end

