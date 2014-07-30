Feature: Editing pathology case
  User should be able to edit pathology case information

  @javascript
  Scenario: User editing an abstraction with a dynamic list
    Given abstraction schemas are set
    And pathology cases with the following information exist
      | Note Text                 | Patient ID |
      |Hello, you look good to me.|      1     |
    And surgeries with the following information exist
      | Surgery Case ID | Surgery Case Number | Patient ID |
      |      100        | OR-123              |     1      |
      |      101        | OR-124              |     1      |
      |      102        | OR-125              |     2      |
    And I go to the last pathology case edit page
    And I choose "Rejected" within the first ".has_surgery .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "OR-124"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "101"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
