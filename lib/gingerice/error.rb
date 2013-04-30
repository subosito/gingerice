module Gingerice
  class Error < StandardError; end
  class ConnectionError < Error; end
  class ParseError < Error; end
end
