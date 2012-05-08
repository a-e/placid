module Placid
  class Config
    class << self
      attr_accessor :rest_url

      def default_url
        'http://localhost'
      end
    end
  end
end

Placid::Config.rest_url = Placid::Config.default_url

