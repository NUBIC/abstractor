# Abstractor Changelog
=======

## 4.4.4
Released on June 24, 2015

* Source type 'custom suggestion' with source method blow up when being displayed.
See https://github.com/NUBIC/abstractor/issues/121

* Rails 4 removed the defaults cols and rows for text areas.  Hardcode them back.
See https://github.com/NUBIC/abstractor/issues/125

## 4.4.3
Released on June 5, 2015

* For numeric and numeric_list rules:
** Skip sentimental suggestions if canonical was detected
** Pick numeric value closest to matched predicate but not separated by comma or semicolon for sentinental matches

See https://github.com/NUBIC/abstractor/issues/64

## 4.4.2
Released on June 2, 2015

* Generate suggestions for numerical values set for name_values schemas
See https://github.com/NUBIC/abstractor/issues/64

* Use Abstractor::Enum values for abstraction object types
See https://github.com/NUBIC/abstractor/issues/114

* Do not create unknown suggestion with empty source if unknown suggestion exists.
See https://github.com/NUBIC/abstractor/issues/115

* Generate suggestions for numerical values limited by a list of possible values for name_values schemas
See https://github.com/NUBIC/abstractor/issues/113

## 4.4.1
Released on May 11, 2015

* Correct accidental comment out of rake call in install generator.
See https://github.com/NUBIC/abstractor/issues/103

## 4.4.0
Released on May 10, 2015

* Make the enum values for querying by suggestion type less obtuse.
See https://github.com/NUBIC/abstractor/issues/111

* Support querying abstractable entities by abstraction status that limits abstractions to ones 'actually answered'.
See https://github.com/NUBIC/abstractor/issues/110

* Sentinental groups: remove suggestions and sources for unlinked abstractions
See https://github.com/NUBIC/abstractor/issues/109

* Sentinental groups: remove unlinked abstractions after regrouping.
See https://github.com/NUBIC/abstractor/issues/108

* Make sentinental groups support re-abstraction
See https://github.com/NUBIC/abstractor/issues/107

* Fix failing sentinental groups spec.
See https://github.com/NUBIC/abstractor/issues/106

* Make sentinental groups respect namespaced abstractor_subjects.
See https://github.com/NUBIC/abstractor/issues/105

* Update abstractor:setup:stanford_core_nlp to install latest version of Stanford CoreNLP.
See https://github.com/NUBIC/abstractor/issues/103

* Unknown suggestions duplicated across multiple abstractions via API.
See https://github.com/NUBIC/abstractor/issues/102

* Add spec coverage to suggesting 'unknown' through the API.
See https://github.com/NUBIC/abstractor/issues/101

* Add container to resource detailing an abstraction schema.
See https://github.com/NUBIC/abstractor/issues/100

* Add support for sentinental groups
https://github.com/NUBIC/abstractor/issues/98

* Add support for a specifying a display order for abstractor object values to be displayed for editing.
https://github.com/NUBIC/abstractor/issues/97

* Misses text matches.
https://github.com/NUBIC/abstractor/issues/95

## 4.3.3
Released on April 25, 2015

* Replace rest-client gem with httparty gem.
See https://github.com/NUBIC/abstractor/issues/99

## 4.3.2
Released on March 28, 2015

* Add URI to post back suggestions to the message posted to a custom NLP provider.
See https://github.com/NUBIC/abstractor/issues/93

* Truncated sources in user interface due to not escaping characters like '<' or '>'.
See https://github.com/NUBIC/abstractor/issues/92

## 4.3.1
Released on March 24, 2015

* Allow for finer grained querying of abstractable entities by suggestion type and specific abstraction schemas.
See https://github.com/NUBIC/abstractor/issues/91

## 4.3.0
Released on March 17, 2015

* Add columns to abstractor object values to store the representation of the value in a standard vocabulary.
See https://github.com/NUBIC/abstractor/issues/90

* Add a column to abstractor object values to store arbitrary properties.
See https://github.com/NUBIC/abstractor/issues/89

* Create a resource detailing an abstraction schema.
See https://github.com/NUBIC/abstractor/issues/88

* Add URI to display the details of an abstraction schema to the message posted to a custom NLP provider.
See https://github.com/NUBIC/abstractor/issues/87

## 4.2.3
Released on March 3, 2015

* Empower the removal of unreviewed suggestions not matching current suggestions upon re-abstraction for source type 'custom suggestion'.
See https://github.com/NUBIC/abstractor/issues/84

* Add support for text abstractor object type.
See https://github.com/NUBIC/abstractor/issues/85

* Add support for custom NLP suggestion providers.
See https://github.com/NUBIC/abstractor/issues/82


## 4.2.2
Released on February 18, 2015

* Lighten up gemspec requirements for coffee-rails gem.
See https://github.com/NUBIC/abstractor/issues/83

## 4.2.1
Released on February 18, 2015

* Require at jquery-rails 4.0.0 or greater.
See https://github.com/NUBIC/abstractor/issues/83


## 4.2.0
Released on February 18, 2015

* Make sure the gem and its test suite are compatible with Rails 4.2
See https://github.com/NUBIC/abstractor/issues/83

## 4.1.5
Released on February 3, 2015

* Allow to specify abstraction schemas while adding/removing abstractions.
See https://github.com/NUBIC/abstractor/issues/81

## 4.1.4
Released on January 20, 2015

* The setup script should update default AbstractorSectionType regular expressions.
See https://github.com/NUBIC/abstractor/issues/80

## 4.1.3
Released on January 20, 2015

* Parsing document sections: regex does not correctly identify end of section.
See https://github.com/NUBIC/abstractor/issues/77

## 4.1.2
Released on January 11, 2015

* Add indexes to improve performance.
See https://github.com/NUBIC/abstractor/issues/78

## 4.1.1
Released on November 11, 2014

* Display of sections on pop up showing wrong sections.
See https://github.com/NUBIC/abstractor/issues/66

## 4.1.0
Released on November 11, 2014

* Abstractable: abstractions and abstraction_groups lookup uses ActiveRecord instances.
See https://github.com/NUBIC/abstractor/issues/65

* Abstraction group cardinality check does not take into account namespace.
See https://github.com/NUBIC/abstractor/issues/62

* Add support for constraining an abstractor abstraction source to a section.
See https://github.com/NUBIC/abstractor/issues/57

* Abstraction groups created via UI are not limited by namespace.
See https://github.com/NUBIC/abstractor/issues/55

## 4.0.2
Released on October 24 , 2014

* Abstraction groups are not filtered by subject group for display.
See https://github.com/NUBIC/abstractor/issues/58

* Ui finetunung.
See https://github.com/NUBIC/abstractor/issues/54

* Use CSS to separate abstractions in place of <hr> elements
See https://github.com/NUBIC/abstractor/issues/53

* Group UI: adding group is broken after layout changes
See https://github.com/NUBIC/abstractor/issues/51

## 4.0.1
Released on September 29 , 2014

* Abstraction groups are not filtered by subject group for display.
See https://github.com/NUBIC/abstractor/issues/46

## 4.0.0
Released on September 10 , 2014

* Soft deleted rows should not be included in
abstraction groups.
See https://github.com/NUBIC/abstractor/issues/45

* Replace hard coded values with enum values.
See https://github.com/NUBIC/abstractor/issues/43

* Improve the display of version history for an
abstraction.
See https://github.com/NUBIC/abstractor/issues/42

* Force the loading of all dependent JavaScript
into the host application.
See https://github.com/NUBIC/abstractor/issues/40

* Make the abstractor:install generator smarter
about inserting default configuration.
See https://github.com/NUBIC/abstractor/issues/38

* Remove cruft left over from the extraction of
the gem from original application: CSS, JavaScript.
See https://github.com/NUBIC/abstractor/issues/39

* Remove all inline JavaScript
(and convert to CoffeeScript).
See https://github.com/NUBIC/abstractor/issues/37

* Allow the setup of abstraction schemas to be
namespaced.
See https://github.com/NUBIC/abstractor/issues/35

* Upgrade to Rails 4.
See https://github.com/NUBIC/abstractor/issues/34

## 2.1.2
Released on August 7, 2014

* An 'unknown' suggestion should be able to display
multiple sources.
See https://github.com/NUBIC/abstractor/issues/32

* Marking an entire group of abstractions or all
abstractions does not seem to effect abstractions
created with no suggestions.
See https://github.com/NUBIC/abstractor/issues/31

## 2.1.01
Released on August 4, 2014

* Abstraction status should not include deleted abstractions
See https://github.com/NUBIC/abstractor/issues/29

## 2.1.0
Released on August 3, 2014

* Listing abstractions for an abstractable entity
that 'need review' or are 'reviewed' should be
based on abstractions that have been answered.
This change involved replacing the method
Abstactor::Abstractable#abstractor\_abstractions\_by\_abstractor\_suggestion\_status
with Abstactor::Abstractable#abstractor\_abstractions\_by\_abstractor\_abstraction\_status.
See https://github.com/NUBIC/abstractor/issues/23
* Querying abstractions that 'need review' or are
'reviewed' should not consider 'blanked'
abstractions 'reviewed'
See https://github.com/NUBIC/abstractor/issues/24
* If a user manually adds a row of grouped
abstractions, indirect sources don't work.
See https://github.com/NUBIC/abstractor/issues/25
* Removal of abstractions from an abstractable
entity should include removal of indirect sources.
See https://github.com/NUBIC/abstractor/issues/26
* Support the storage and display of a
'explanation' of a 'custom suggestion'.
See https://github.com/NUBIC/abstractor/issues/27
* Rename method filtering abstractions on an abstractable entity.
See https://github.com/NUBIC/abstractor/issues/28

Existing users with abstactions being generated
by a 'custom suggestion' will need to change the
implementation of each 'custom\_method' to return
an array of hashes instead of an array of strings.
See the documenation for Abstactor::AbstractorSubject#abstract\_custom\_suggestion
for more details.

Existing users with abstractions generated from
a 'custom suggestion' source type
may want to migrate data by setting the
Abstractor::AbstractorSuggestionSource#custom\_explanation
to align with what follow for new abstactions.

Existing users will also need to use the
the renamed method to filter abstactions on
an abstractable entity.  New method:
Abstractor::Abstractable#abstractor\_abstractions\_by\_abstractor\_abstraction\_status.

## 2.0.1

Released on July 31, 2014

* Display in the user interface the source specified
in the suggestion source.
See https://github.com/NUBIC/abstractor/issues/20
* The system should be able to handle a nil
'from_method' setup for an abstraction source.
See https://github.com/NUBIC/abstractor/issues/21

## 2.0.0

Released on July 29, 2014

* Improve the test coverage of supporting a dynamic list
abstractor object type.
See https://github.com/NUBIC/abstractor/issues/16
* Querying abstractions that 'need review' or are
'reviewed' should be based on whether an
abstraction has been answered.
See https://github.com/NUBIC/abstractor/issues/19
* Add support for selecting indirect sources as
evidence of an abstraction.
See https://github.com/NUBIC/abstractor/issues/18

Bumping to version 2.0 because this
commit includes a migration that:

* adds a column abstractor\_abstraction\_source\_type\_id
to abstractor\_abstraction\_sources, which is a
foreign key to a new table
abstractor\_abstraction\_source\_types.  Three
possble types: 'nlp suggestion',
'custom suggestion' and 'indirect'.

* moves abstractor\_rule\_type\_id from
abstractor\_subjects to
abstractor\_abstraction\_sources and now
confines its use to sources of only
type 'nlp suggestion'

Existing users will need to migrate data
This will entail creating a script to
update abstractor\_abstraction\_source_type\_id
and abstractor\_rule\_type\_id
for exisitng entries in
abstractor\_abstraction\_sources.

## 1.0.23

Released on July 16, 2014

* Support a dynamic list abstractor object type.
See https://github.com/NUBIC/abstractor/issues/16

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