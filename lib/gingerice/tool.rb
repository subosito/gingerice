module Gingerice
  class Tool
    class << self
      def check(text, lang = 'US')
        parser = Parser.new(lang)
        parser.parse(text)
      end
    end
  end
end

