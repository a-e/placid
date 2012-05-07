Gem::Specification.new do |s|
  s.name = "placid"
  s.version = "0.0.1"
  s.summary = "Models from REST"
  s.description = <<-EOS
  EOS
  s.authors = ["Eric Pierce"]
  s.email = "epierce@automation-excellence.com"
  s.homepage = "http://github.com/a-e/placid"
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'hashie'
  s.add_dependency 'json'
  s.add_dependency 'rest-client'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard' # For documentation
  s.add_development_dependency 'redcarpet' # For YARD / Markdown
  s.add_development_dependency 'rcov'

  s.files = `git ls-files`.split("\n")
  # Don't include .jar files in distribution
  s.files.reject! { |f| f =~ /.jar$/ }

  s.require_path = 'lib'
end
