module Placid
  # Error parsing a JSON response
  class JSONParseError < RuntimeError
    def initialize(message, data='')
      super(message)
      @data = data
    end
    attr_reader :data
  end

  # Error connecting to the REST API
  class RestConnectionError < RuntimeError
  end
end
