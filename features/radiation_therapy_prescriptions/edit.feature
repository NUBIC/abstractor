Feature: Editing radiation therapy prescription
  User should be able to edit radiation therapy prescription information

  @javascript
  Scenario: Editing an abstraction with radio button list
    Given radiation therapy prescription abstraction schema is set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id" within ".has_laterality"
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
    Given radiation therapy prescription abstraction schema is set
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
  Scenario: Viewing abstraction groups with suggestions
    Given radiation therapy prescription abstraction schema is set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should see "Anatomical location"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Needs review" selected
    And I should not see an ".edit_link" element
    And I should see "Add group"
    And I should not see "Delete group"

  @javascript
  Scenario: Adding abstraction groups to abstraction groups with suggestions
    Given radiation therapy prescription abstraction schema is set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | treat the temporal lobe                 |
    When I go to the last radiation therapy prescription edit page
    And I follow "Add group"
    And I wait for the ajax request to finish
    And ".abstractor_abstraction_actions" in the last ".abstractor_abstraction_group" should contain selector ".delete_link"
    And ".abstractor_abstraction_actions" in the first ".abstractor_abstraction_group" should not contain selector ".delete_link"
    And ".abstractor_abstraction_value" in the last ".abstractor_abstraction" should contain selector ".edit_link"