module Placid
  class Config
    @@rest_url = 'http://localhost'
    class << self
      attr_accessor :rest_url
    end
  end
end

