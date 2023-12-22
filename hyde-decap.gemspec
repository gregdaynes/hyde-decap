require File.expand_path('../lib/hyde_decap.rb', __FILE__)

Gem::Specification.new do |s|
  s.name = "hyde-decap"
  s.version = Hyde::Decap::VERSION
  s.summary = "Plugin for jekyll to add Decap CMS"
  s.description = "Hyde Decap is a plugin for Jekyll to add Decap CMS."
  s.authors = ["Gregory Daynes"]
  s.email   = "email@gregdaynes.com"
  s.homepage = "https://github.com/gregdaynes/hyde-decap"
  s.license = "MIT"

  s.files = Dir["{lib}/**/*.rb", "{lib}/**/*.html"]
  s.require_path = 'lib'

  s.add_development_dependency "jekyll", ">= 4.0", "< 5.0"
end
