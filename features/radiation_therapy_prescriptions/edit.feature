Feature: Editing radiation therapy prescription
  User should be able to edit radiation therapy prescription information

  @javascript
  Scenario: Editing an abstraction with radio button list
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I choose "Rejected" within the first ".has_laterality .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".has_laterality"
    And I choose "left"
    Then the "left" checkbox within ".has_laterality" should be checked
    And I press "Save"
    And I go to the last radiation therapy prescription edit page
    And ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "left"
    And I click on ".edit_link" within the first ".has_laterality"
    And I wait for the ajax request to finish
    Then the "left" checkbox within ".has_laterality" should be checked
    When I check "input#abstractor_abstraction_not_applicable" within the first ".has_laterality"
    Then the "left" checkbox within ".has_laterality" should not be checked
    When I press "Save"
    And I go to the last radiation therapy prescription edit page
    Then ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "not applicable"

  @javascript
  Scenario: Adding and removing abstraction groups
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should not see "Delete group"
    And I should see "Add group"
    When I follow "Add group"
    And I wait for the ajax request to finish
    And I should see "Delete group"
    And ".abstractor_abstraction_value" in the last ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the last ".abstractor_abstraction" should contain selector ".edit_link"
    When I go to the last radiation therapy prescription edit page
    And I should see "Delete group"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain selector ".edit_link"
    When I confirm link "Delete group"
    And I wait for the ajax request to finish
    Then I should see "Add group"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And I should not see an ".edit_link" element

  @javascript
  Scenario: Viewing abstraction groups with no suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should see "Anatomical location"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And the "Needs review" radio button within the first ".has_anatomical_location" should be checked
    And I should not see an ".edit_link" element
    And I should see "Add group"
    And I should not see "Delete group"
    And ".abstractor_suggestion_values" in the first ".has_anatomical_location" should contain text "unknown"

  @javascript
  Scenario: Viewing abstraction groups with suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    Then I should see "Anatomical location"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And the "Needs review" radio button within the last ".has_anatomical_location" should be checked
    And I should not see an ".edit_link" element
    And I should see "Add group"
    And I should not see "Delete group"
    And ".abstractor_suggestion_values" in the first ".has_anatomical_location" should contain text "temporal lobe"

  @javascript
  Scenario: Adding abstraction groups to abstraction groups with suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | treat the temporal lobe                 |
    When I go to the last radiation therapy prescription edit page
    And I follow "Add group"
    And I wait for the ajax request to finish
    And ".abstractor_abstraction_actions" in the last ".abstractor_abstraction_group" should contain selector ".delete_link"
    And ".abstractor_abstraction_actions" in the first ".abstractor_abstraction_group" should not contain selector ".delete_link"
    And ".abstractor_abstraction_value" in the last ".abstractor_abstraction" should contain selector ".edit_link"

  @javascript
  Scenario: User setting the value of an abstraction schema with a date object type in a group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I choose "Rejected" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".has_radiation_therapy_prescription_date" should contain text "2014-06-03"

  @javascript
  Scenario: User setting all the values to 'not applicable' in an abstraction group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then the "Needs review" radio button within the first ".has_anatomical_location" should be checked
    And the "Needs review" radio button within the first ".has_laterality" should be checked
    And the "Needs review" radio button within the first ".has_radiation_therapy_prescription_date" should be checked
    And ".abstractor_abstraction_value" in the first ".has_anatomical_location" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_radiation_therapy_prescription_date" should contain text "[Not set]"
    When I confirm link "Not applicable group" in the first ".abstractor_abstraction_group"
    And I wait for the ajax request to finish
    Then the "Rejected" radio button within the first ".has_anatomical_location" should be checked
    And the "Rejected" radio button within the first ".has_laterality" should be checked
    And the "Rejected" radio button within the first ".has_radiation_therapy_prescription_date" should be checked
    And ".abstractor_abstraction_value" in the first ".has_anatomical_location" should contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".has_radiation_therapy_prescription_date" should contain text "not applicable"

  @javascript
  Scenario: User setting all the values to 'unknown' in an abstraction group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then the "Needs review" radio button within the first ".has_anatomical_location" should be checked
    And the "Needs review" radio button within the first ".has_laterality" should be checked
    And the "Needs review" radio button within the first ".has_radiation_therapy_prescription_date" should be checked
    And ".abstractor_abstraction_value" in the first ".has_anatomical_location" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_radiation_therapy_prescription_date" should contain text "[Not set]"
    When I confirm link "Unknown group" in the first ".abstractor_abstraction_group"
    And I wait for the ajax request to finish
    Then the "Accepted" radio button within the first ".has_anatomical_location" should be checked
    And the "Accepted" radio button within the first ".has_laterality" should be checked
    And the "Accepted" radio button within the first ".has_radiation_therapy_prescription_date" should be checked
    And ".abstractor_abstraction_value" in the first ".has_anatomical_location" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".has_laterality" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".has_radiation_therapy_prescription_date" should contain text "unknown"