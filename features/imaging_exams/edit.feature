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
    And I should see "Diagnosis" within ".has_diagnosis"
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

  @javascript
  Scenario: Groups displayed in UI should maintain namespace
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  Then I should see 1 ".has_diagnosis" within the last ".abstractor_subject_groups_container"

  When I go to the namespace_type "Discerner::Search" and namespace_id 2 sent to the last imaging exam edit page
  Then I should see 0 ".has_diagnosis" within the last ".abstractor_subject_groups_container"

  @javascript
  Scenario: Groups displayed in UI should contain only abstractions related to selected namespace
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  And imaging exam with accession number "123" is abstracted under namespace_type "Discerner::Search" and namespace_id 2

  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  Then I should see 1 ".has_diagnosis" within the last ".abstractor_subject_groups_container"

  When I go to the namespace_type "Discerner::Search" and namespace_id 2 sent to the last imaging exam edit page
  Then I should see 1 ".has_diagnosis" within the last ".abstractor_subject_groups_container"

  @javascript
  Scenario: Adding groups in UI should add only abstractions related to selected namespace
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  And I confirm link "Add group" in the last ".abstractor_subject_groups_container"
  And I wait for the ajax request to finish
  Then I should see 2 ".has_diagnosis" within the last ".abstractor_subject_groups_container"
  And "fieldset" in the last ".abstractor_subject_groups_container" should contain text "Delete group"

  @javascript
  Scenario: Editing groups in UI should edit only abstractions related to selected namespace
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  And I confirm link "Add group" in the last ".abstractor_subject_groups_container"
  And I wait for the ajax request to finish
  When I click on ".edit_link" within the last ".has_diagnosis"
  And I wait for the ajax request to finish
  And I fill in "input.combobox" autocompleter within the last ".has_diagnosis" with "Ataxia"
  When I press "Save"
  And I go to the namespace_type "Discerner::Search" and namespace_id 2 sent to the last imaging exam edit page
  Then I should not see "Ataxia"

  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  Then I should see "Ataxia"

  @javascript
  Scenario: Adding groups in UI should respect group cardinality
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                           | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | Hello, you look good to me.         |      1     | 1/1/2014 |  123             | Discerner::Search  |     3       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 3 sent to the last imaging exam edit page
  Then I should see "Score 1" within ".has_score_1"
  And I should see "Falls" within ".has_falls"
  And "fieldset" in the first ".abstractor_subject_groups_container" should contain text "Add group"
  And "fieldset" in the first ".abstractor_subject_groups_container" should not contain text "Delete group"
  And "fieldset" in the last ".abstractor_subject_groups_container" should not contain text "Add group"
  And "fieldset" in the last ".abstractor_subject_groups_container" should not contain text "Delete group"

  When I confirm link "Add group" in the first ".abstractor_subject_groups_container"
  And I wait for the ajax request to finish
  Then I should see 2 ".has_score_1" within the first ".abstractor_subject_groups_container"
  And the element ".abstractor_group_add_link" in the first ".abstractor_subject_groups_container" should not be visible

  When I go to the namespace_type "Discerner::Search" and namespace_id 3 sent to the last imaging exam edit page
  Then I should see 2 ".has_score_1" within the first ".abstractor_subject_groups_container"
  And the element ".abstractor_group_add_link" in the first ".abstractor_subject_groups_container" should not be visible

  When I confirm link "Delete group" in the first ".abstractor_subject_groups_container"
  And I wait for the ajax request to finish
  Then I should see 1 ".has_score_1" within the first ".abstractor_subject_groups_container"
  And the element ".abstractor_group_add_link" in the first ".abstractor_subject_groups_container" should be visible

  @javascript
  Scenario: New group of abstractions displays valid sources
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                                                             | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | I like little my the best!\nfavorite moomin:\nThe groke is the bomb!  |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  And I confirm link "Add group" in the last ".abstractor_subject_groups_container"
  And I wait for the ajax request to finish
  Then I should see 2 ".abstractor_abstraction_source_tooltip_img" within the last ".has_diagnosis"

  When I click within last ".has_diagnosis span.abstractor_abstraction_source_tooltip_img"
  Then I should see an ".ui-dialog_abstractor" element
  And ".ui-dialog-titlebar" should contain text "ImagingExam note_text favorite moomin"
  And ".ui-dialog-content" should contain text "The groke is the bomb!"


  Scenario: Edited abstraction with section sources displays valid sources
  Given abstraction schemas are set
  And imaging exams with the following information exist
    | Note Text                                                             | Patient ID | Date     | Accession Number | Namespace          |Namespace ID |
    | I like little my the best!\nfavorite moomin:\nThe groke is the bomb!  |      1     | 1/1/2014 |  123             | Discerner::Search  |     1       |
  When I go to the namespace_type "Discerner::Search" and namespace_id 1 sent to the last imaging exam edit page
  When I choose "Rejected" within the last ".has_diagnosis"
  And I wait for the ajax request to finish
  When I click on ".edit_link" within the last ".has_diagnosis"
  And I wait for the ajax request to finish
  Then I should see 2 ".abstractor_abstraction_source_tooltip_img" within the last ".has_diagnosis .edit_abstractor_abstraction"
  When I click within last ".has_diagnosis .edit_abstractor_abstraction span.abstractor_abstraction_source_tooltip_img"
  Then I should see an ".ui-dialog_abstractor" element
  And ".ui-dialog-titlebar" should contain text "ImagingExam note_text favorite moomin"
  And ".ui-dialog-content" should contain text "The groke is the bomb!"

