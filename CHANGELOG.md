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