# Abstractor Changelog
=======

## 1.0.22

Released on June 19, 2014

* Clicking a label on a suggestion status radio button always updates the first suggestion on the page.
See https://github.com/NUBIC/abstractor/issues/15


## 1.0.21

Released on June 19, 2014

* Implement support for the 'custom' rule type to allow for the custom generation of suggestions.
See https://github.com/NUBIC/abstractor/issues/14
* Remove dependency on 'nubic-gem-tasks' gem and remove NUBIC gem server as a source.

## 1.0.20

Released on June 17, 2014

* Allow an entire set of abstractions for an abstractable entity to be marked as  'not applicable ' or 'unknown'.
See https://github.com/NUBIC/abstractor/issues/11

## 1.0.19

Released on June 16, 2014

* Setting an entire abstraction group to something else than 'unknown' for an abstraction with a suggestion of 'unknown' updates more than necessary.
See https://github.com/NUBIC/abstractor/issues/12

## 1.0.18

Released on June 16, 2014

* Allow an entire abstraction group to be marked as 'not applicable ' or 'unknown'.
See https://github.com/NUBIC/abstractor/issues/10

## 1.0.17

Released on June 12, 2014

* Change the confirmation of an abstractor suggestion to a radio button list from a select.
See https://github.com/NUBIC/abstractor/issues/9

## 1.0.16

Released on June 11, 2014

* Point back to louismullie/stanford-core-nlp
master branch for the stanford-core-nlp gem.
See https://github.com/NUBIC/abstractor/issues/8

* Support date as an object type for abstraction
schemas.
See https://github.com/NUBIC/abstractor/issues/6

## 1.0.15

Released on May 28, 2014

* Support the display of 'unknown' and 'not applicable'
abstractions when pivoting.
See https://github.com/NUBIC/abstractor/issues/5

## 1.0.14

Released on May 28, 2014

* Removing abstractions should easily be confined to
only unreviewed abstractions.
See https://github.com/NUBIC/abstractor/issues/1

* Display the text from the abstractor\_suggestion\_sources
table instead of abstractor\_abstraction\_sources in the
user interface.
See https://github.com/NUBIC/abstractor/issues/2

* Display the 'sentence match value' instead of the
'match value' in the user interface.
See https://github.com/NUBIC/abstractor/issues/3

## 1.0.13

Released on May 27, 2014

* Pivoting abstractions should not mix grouped
and non-grouped abstractions.

* Make Abstractor::Abstractable::pivot_abstractions
only include non-grouped abstractions.

* Abstractor::Abstractable::pivot_abstractions
should return abstractable entities that have
not been abstracted.

* Allow Abstractor::Abstractable::abstractor\_subjects
to be filtered to grouped and non-grouped
abstractor subjects.

* Allow Abstractor::Abstractable::abstractor\_abstraction_schemas
to be filtered to grouped and non-grouped
abstractor abstraction schemas.

## 1.0.12

Released on May 15, 2014

* Use the
ActionView::Helpers::TextHelper#simple_format
when displaying abstractor abstraction.from_method.
in the abstractor/abstractor_abstractions/edit.html.haml
This helps us take advantage of text with useful
linke break/spacing formatting.

* Trying automate the install of the gem and setup of testbed
with newer standard version of Stanford Core NLP.
Not working completely yet.


## 1.0.11

Released on May 13, 2014

* Add support for instructing the Abstractor::Parser
to treat new lines always as sentences.
Will need to make this configurable per
abstractor abstraction source later.

* Use the
ActionView::Helpers::TextHelper#simple_format
when displaying abstractor abstraction source.
This helps us take advantage of text with useful
linke break/spacing formatting.


## 1.0.10

Released on May 8, 2014

* Add a rake task abstractor:setup:stanford\_core_nlp to retrieve
  and unzip a built version of the Stanford Core NLP package
  from: http://louismullie.com/treat/stanford-core-nlp-minimal.zip/
  Louis Mullie is the maintainer of the stanford-core-nlp gem
  https://github.com/louismullie/stanford-core-nlp.

## 1.0.9

Released on May 5, 2014

* Make rake task abstractor:setup:system not
insert duplicates if run more than once.

* Make Abstractor::InstallGenerator less potentially
destructive for an innocent user with some other
pending migrations they were not expecting to
be migrated yet.

## 1.0.8

Released on May 2, 2014

* Performance optimization in
Abstractor::AbstractorSubject#abstract\_sentential\_value
did not have a case statement for PostgreSQL.

## 1.0.7

Released on May 2, 2014

* Wrap delete link for abstraction groups with
Abstractor::UserInterface::abstractor\_relative\_path
in app/views/abstractor/abstractor\_abstraction\_groups


## 1.0.6

Released on May 2, 2014

* Abstractor::UserInteface::abstractor_relative_path do not
prepend a relative url root if the path alreadys includes the
relative url root.  Mysterious Rails 3 Engine issue with
URL helpers.

## 1.0.5

Released on May 2, 2014

*  Enable the views to deal with a
relative url root set via in
config.action\_controller.relative\_url\_root

## 1.0.4

Released on May 1, 2014

* Building from master branch instead of rails-3.2 branch.

## 1.0.3

Released on April 30, 2014

* Fix Abstractor::Abstractable::ClassMethods::pivot_abstractions
and Abstractor::Abstractable::ClassMethods::pivot\_grouped_abstractions

* Fix generator to allow for local customization of Abstractor
controllers.  For example, to add a check for authetication/authorization.


## 1.0.2

Released on April 14, 2014

* Optimize performance of Abstractor::AbstractorSubject#abstract\_sentential_value.
  Only restrict Abstractor::AbstractorObjectValue found via a SQL like.  Optimization
  in 1.0.1 only applied to Abstractor::AbstractorObjectValueVariant.

## 1.0.1

Released on April 9, 2014

* Optimize performance of Abstractor::AbstractorSubject#abstract\_sentential_value.
  Only search for terms naively found via a SQL like.
  Reduce number of queries via caching.
* Add some more negation cues Abstractor::NegationDetection:::manual\_negated\_match_value

## 1.0.0

Released on March 24, 2014

* Initial release