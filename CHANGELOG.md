# Abstractor Changelog

=======

## 1.0.0

Released on March 24, 2014

* Initial release

## 1.0.1

Released on April 9, 2014

* Optimize performance of {Abstractor::AbstractorSubject#abstract\_sentential_value}.
  Only search for terms naively found via a SQL like.
  Reduce number of queries via caching.
* Add some more negation cues {Abstractor::NegationDetection:::manual\_negated\_match_value}

## 1.0.2

Released on April 14, 2014

* Optimize performance of {Abstractor::AbstractorSubject#abstract\_sentential_value}.
  Only restrict Abstractor::AbstractorObjectValue found via a SQL like.  Optimization
  in 1.0.1 only applied to Abstractor::AbstractorObjectValueVariant.

## 1.0.3

Released on April 30, 2014

* Fix Abstractable::ClassMethods::pivot_abstractions
and Abstractable::ClassMethods::pivot_\_grouped_abstractions

* Fix generator to allow for local customization of Abstractor
controllers.  For example, to add a check for authetication/authorization.