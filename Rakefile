require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*.rb'
  t.rspec_opts = ['--color', '--format doc']
  t.rcov = true
  t.rcov_opts = [
    '--exclude /.gem/,/gems/,spec',
  ]
end

