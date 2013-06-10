Gem::Specification.new do |s|
  s.name = "placid"
  s.version = "0.0.7"
  s.summary = "Models from REST"
  s.description = <<-EOS
    Placid is an ActiveRecord-ish model using a REST API for storage. The REST API
    can be any backend you choose or create yourself, provided it follows some basic
    conventions.
  EOS
  s.authors = ["Eric Pierce"]
  s.email = "epierce@automation-excellence.com"
  s.homepage = "http://github.com/a-e/placid"
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'hashie', '>= 2.0.4'
  s.add_dependency 'json'
  s.add_dependency 'rest-client'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard' # For documentation
  s.add_development_dependency 'redcarpet' # For YARD / Markdown

  if RUBY_VERSION < "1.9"
    s.add_development_dependency 'rcov'
  else
    s.add_development_dependency 'simplecov'
  end

  s.files = `git ls-files`.split("\n")

  s.require_path = 'lib'
end
