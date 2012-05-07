# This file includes RSpec configuration that is needed for all spec testing.

require 'rspec'
require 'rspec/autorun' # needed for RSpec 2.6.x
require 'placid'
require 'json'

RSpec.configure do |config|
  config.color_enabled = true
  config.include Placid
  config.include Placid::Helper
end
