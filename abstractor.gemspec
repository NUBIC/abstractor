$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'abstractor/version'
require 'abstractor/parser'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'abstractor'
  s.version     = Abstractor::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Michael Gurley, Yulia Bushmanova']
  s.email       = ['m-gurley@northwestern.edu, y.bushmanova@gmail.com']
  s.summary     = 'Rails engine that provides functionality for the defintion of discrete data points to be derived from narrative text via natural language processing (NLP) and the presentation of NLP-derived abstracted data points for confirmation/revision.'
  s.description = 'Rails engine that provides functionality for the defintion of discrete data points to be derived from narrative text via natural language processing (NLP) and the presentation of NLP-derived abstracted data points for confirmation/revision.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 3.2'
  s.add_dependency 'jquery-rails', '~> 3.1', '>= 3.1.0'
  s.add_dependency 'jquery-ui-rails', '~> 4.2', '>= 4.2.0'
  s.add_dependency 'haml', '~> 4.0.5', '>= 4.0.5'
  s.add_dependency 'sass-rails', '~> 3.2.6', '>= 3.2.6'
  s.add_dependency 'paper_trail', '~> 3.0.0', '>= 3.0.0'
  s.add_dependency 'stanford-core-nlp', '~> 0.5.1', '>= 0.5.1'

  s.add_development_dependency 'sqlite3', '~> 1.3.8', '>= 1.3.8'
  s.add_development_dependency 'rspec-rails', '~> 2.14.1', '>= 2.14.1'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4.0', '>= 4.4.0'
  s.add_development_dependency 'cucumber-rails', '~> 1.4.0', '>= 1.4.0'
  s.add_development_dependency 'capybara', '~> 2.2.1', '>= 2.2.1'
  s.add_development_dependency 'selenium-webdriver', '~> 2.40.0', '>= 2.40.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0', '>= 1.2.0'
  s.add_development_dependency 'ansi', '~> 1.4.3', '>= 1.4.3'
  s.add_development_dependency 'sprockets', '~> 2.2.1', '>= 2.2.1'
  s.add_development_dependency "nubic-gem-tasks", '~> 1.0', '>= 1.0.0'
end