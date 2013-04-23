module Placid
  # Generic Placid exception
  class PlacidError < RuntimeError
  end

  # Error parsing a JSON response
  class JSONParseError < PlacidError
    def initialize(message, data='')
      super(message)
      @data = data
    end
    attr_reader :data
  end

  # Error connecting to the REST API
  class RestConnectionError < PlacidError
  end

  # Error with request path
  class PathError < PlacidError
  end
end
