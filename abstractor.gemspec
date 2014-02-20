$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'abstractor/version'
require 'abstractor/parser'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'abstractor'
  s.version     = Abstractor::VERSION
  s.authors     = ['Michael Gurley, Yulia Bushmanova']
  s.email       = ['m-gurley@northwestern.edu, y.bushmanova@gmail.com']
  s.summary     = 'Rails engine that provides functionality for the defintion of discrete data points to be derived from narrative text via natural language processing (NLP) and the presentation of NLP-derived abstracted data points for confirmation/revision.'
  s.description = 'Rails engine that provides functionality for the defintion of discrete data points to be derived from narrative text via natural language processing (NLP) and the presentation of NLP-derived abstracted data points for confirmation/revision.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 3.2'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'haml'
  s.add_dependency 'sass-rails'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'cucumber-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'ansi'
  s.add_development_dependency 'sprockets'
end