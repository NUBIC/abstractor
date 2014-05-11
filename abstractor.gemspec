$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'abstractor/version'
require 'abstractor/parser'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'abstractor'
  s.version     = Abstractor::VERSION
  s.licenses    = ['MIT']
  s.homepage    = 'http://github.com/nubic/abstractor'
  s.authors     = ['Michael Gurley, Yulia Bushmanova']
  s.email       = ['michaeljamesgurley@gmail.com, y.bushmanova@gmail.com']
  s.summary     = 'A Rails engine gem for deriving discrete data points from narrative text via natural language processing (NLP).  The gem includes a user interface to present the abstracted data points for confirmation/revision by curator.'
  s.description = 'A Rails engine gem for deriving discrete data points from narrative text via natural language processing (NLP).  The gem includes a user interface to present the abstracted data points for confirmation/revision by curator.'
  s.required_ruby_version = '>= 1.9.3'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 3.2'
  s.add_dependency 'jquery-rails', '~> 3.1', '>= 3.1.0'
  s.add_dependency 'jquery-ui-rails', '~> 4.2', '>= 4.2.0'
  s.add_dependency 'haml', '~> 4.0.5', '>= 4.0.5'
  s.add_dependency 'sass-rails', '~> 3.2.6', '>= 3.2.6'
  s.add_dependency 'paper_trail', '~> 3.0.0', '>= 3.0.0'
  s.add_dependency 'stanford-core-nlp', '~> 0.5.1', '>= 0.5.1'
  s.add_dependency 'rubyzip', '~> 1.1.0', '>= 1.1.0'

  s.add_development_dependency 'sqlite3', '~> 1.3.8', '>= 1.3.8'
  s.add_development_dependency 'rspec-rails', '~> 2.14.1', '>= 2.14.1'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4.0', '>= 4.4.0'
  s.add_development_dependency 'cucumber-rails','~> 1.4.0', '>= 1.4.0'
  s.add_development_dependency 'capybara', '~> 2.2.1', '>= 2.2.1'
  s.add_development_dependency 'selenium-webdriver', '~> 2.40.0', '>= 2.40.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0', '>= 1.2.0'
  s.add_development_dependency 'ansi', '~> 1.4.3', '>= 1.4.3'
  s.add_development_dependency 'sprockets', '~> 2.2.1', '>= 2.2.1'
  s.add_development_dependency "nubic-gem-tasks", '~> 1.0.0', '>= 1.0.0'
  s.add_development_dependency "yard", '~> 0.8.7.3', '>= 0.8.7.3'
  s.add_development_dependency "redcarpet", '~> 3.1.1', '>= 3.1.1'
end