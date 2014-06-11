Abstractor
====
Abstractor is a Rails engine gem for deriving discrete data points
from narrative text via natural language processing.  The gem includes
a user interface to present the abstracted data points for
confirmation/revision by curator.

Reader's note: this README uses [YARD][] markup to provide links to
Abstractor's API documentation. If you aren't already, consider reading it
on [rubydoc.info][] so that the links will be followable.

[YARD]: http://yardoc.org/
[rubydoc.info]: http://rubydoc.info/github/NUBIC/abstractor/master/file/README.md

## Status
[![Gem Version](https://badge.fury.io/rb/abstractor.svg)](http://badge.fury.io/rb/abstractor)

## Requirements

Abstractor works with:

* Ruby 1.9.3, 2.0.0 and 2.1.1
* Rails 3.2 (not Rails 4.0 or later yet)

Some key dependencies are:

* Gems
  * stanford-core-nlp
  * paper\_trail
  * Haml
  * Sass
  * A more exhaustive list can be found in the [gemspec][].
[gemspec]: https://github.com/NUBIC/abstractor/blob/master/abstractor.gemspec

* JavaScript
  * [jQuery](http://jquery.com/)
  * [jQuery UI](https://jqueryui.com/)

* Java
  * [Stanford CoreNLP](http://nlp.stanford.edu/software/corenlp.shtml)
  * [lingscope](http://sourceforge.net/projects/lingscope/)

## Install

Add abstractor to your Gemfile:

```ruby
gem 'abstractor'
```

Add the stanford-core-nlp gem to your Gemfile.  Currently need to use the master branch of the official repository until a new version of the gem is released:

```ruby
gem 'stanford-core-nlp', :git => 'https://github.com/louismullie/stanford-core-nlp', :branch => 'master',
```

Also add the paper\_trail gem to your Gemfile (if it is not already there):

```ruby
gem 'paper_trail'
```

Bundle, install, and migrate.  The abstractor:install generator can take a long time because it needs to download and intall the Stanford CoreNLP library into your application's lib directory:

* bundle install
* bundle exec rails g abstractor:install
* bundle exec rake db:migrate
* bundle exec rake abstractor:setup:system

Install the paper\_trail gem (if it is not already installed in your application).

* bundle exec rails g paper_trail:install
* bundle exec rake db:migrate
