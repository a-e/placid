module Placid
  class Config
    class << self
      attr_accessor :rest_url
    end
  end
end

# Default configuration
Placid::Config.rest_url = 'http://localhost'

