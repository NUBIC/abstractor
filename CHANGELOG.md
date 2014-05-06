# Abstractor Changelog

=======

## 1.0.0

Released on March 24, 2014

* Initial release

## 1.0.1

Released on April 9, 2014

* Optimize performance of Abstractor::AbstractorSubject#abstract\_sentential_value.
  Only search for terms naively found via a SQL like.
  Reduce number of queries via caching.
* Add some more negation cues Abstractor::NegationDetection:::manual\_negated\_match_value

## 1.0.2

Released on April 14, 2014

* Optimize performance of Abstractor::AbstractorSubject#abstract\_sentential_value.
  Only restrict Abstractor::AbstractorObjectValue found via a SQL like.  Optimization
  in 1.0.1 only applied to Abstractor::AbstractorObjectValueVariant.

## 1.0.3

Released on April 30, 2014

* Fix Abstractor::Abstractable::ClassMethods::pivot_abstractions
and Abstractor::Abstractable::ClassMethods::pivot\_grouped_abstractions

* Fix generator to allow for local customization of Abstractor
controllers.  For example, to add a check for authetication/authorization.

## 1.0.4

Released on May 1, 2014

* Building from master branch instead of rails-3.2 branch.

## 1.0.5

Released on May 2, 2014

*  Enable the views to deal with a
relative url root set via in
config.action\_controller.relative\_url\_root

## 1.0.6

Released on May 2, 2014

* Abstractor::UserInteface::abstractor_relative_path do not
prepend a relative url root if the path alreadys includes the
relative url root.  Mysterious Rails 3 Engine issue with
URL helpers.

## 1.0.7

Released on May 2, 2014

* Wrap delete link for abstraction groups with
Abstractor::UserInterface::abstractor\_relative\_path
in app/views/abstractor/abstractor\_abstraction\_groups


## 1.0.8

Released on May 2, 2014

* Performance optimization in
Abstractor::AbstractorSubject#abstract\_sentential\_value
did not have a case statement for PostgreSQL.