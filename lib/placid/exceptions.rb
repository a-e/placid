module Placid
  # Error parsing a JSON response
  class JSONParseError < RuntimeError
  end

  # Error connecting to the REST API
  class RestConnectionError < RuntimeError
  end
end
