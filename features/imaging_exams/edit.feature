Feature: Editing imaging exam
  User should be able to edit namespaced imaging exam information

  @javascript
  Scenario: Editing abstactions in one namespace
    Given abstraction schemas are set
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
    When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
    Then I should see "Dopamine transporter level" within ".has_dopamine_transporter_level"
    And I should see "Anatomical location" within ".has_anatomical_location"
    And I should see "Favorite major Moomin character" within ".has_favorite_major_moomin_character"
    And I should not see "RECIST response criteria"
    And I should not see "Favorite minor Moomin character"

  @javascript
  Scenario: Editing abstactions in another namespace
    Given abstraction schemas are set
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     2       |
    When I go to the namespace_type "Discerner::Search" and namespace_id 2 sent to the last imaging exam edit page
    Then I should see "RECIST response criteria" within ".has_recist_response_criteria"
    And I should see "Anatomical location" within ".has_anatomical_location"
    And I should see "Favorite minor Moomin character" within ".has_favorite_minor_moomin_character"
    And I should not see "Dopamine transporter level"
    And I should not see "Favorite major Moomin character"

  @javascript
  Scenario: Editing abstactions on an imaging exam in multiple namespaces
    Given abstraction schemas are set
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     2       |
    When I go to the namespace_type "Discerner::Search" and namespace_id 2 sent to the last imaging exam edit page
    Then I should see "RECIST response criteria" within ".has_recist_response_criteria"
    And I should see "Anatomical location" within ".has_anatomical_location"
    And I should see "Favorite minor Moomin character" within ".has_favorite_minor_moomin_character"
    And I should not see "Dopamine transporter level"
    And I should not see "Favorite major Moomin character"
    When imaging exam with accession number "123" is abstracted under namespace_type "Discerner::Search" and namespace_id 1
    And I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
    Then I should see "Dopamine transporter level" within ".has_dopamine_transporter_level"
    And I should see "Anatomical location" within ".has_anatomical_location"
    And I should see "Favorite major Moomin character" within ".has_favorite_major_moomin_character"
    And I should not see "RECIST response criteria"
    And I should not see "Favorite minor Moomin character"