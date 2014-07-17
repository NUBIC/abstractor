Feature: Editing imaging exam
  User should be able to edit imaging exam information

  @javascript
  Scenario: User editing an abstraction with a dynamic list
    Given abstraction schemas are set
    And imaging exams with the following information exist
      | Note Text                 |
      |Hello, you look good to me.|
    And I go to the last imaging exam edit page
    And I choose "Rejected" within the first ".has_imaging_confirmed_extent_of_resction_surgery .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "123 (1/1/2014)"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "123"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"