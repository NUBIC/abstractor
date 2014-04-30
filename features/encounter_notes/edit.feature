Feature: Editing encounter note
  User should be able to edit encounter note information

  @javascript
  Scenario: Viewing not reviewed suggestions
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Needs review" selected
    And I should not see an ".edit_link" element

  @javascript
  Scenario: Viewing selected suggestions
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    And I should see an ".edit_link" element

  @javascript
  Scenario: Viewing accepted unknown suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I select "Accepted" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    Then "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Accepted" selected
    And I should not see an ".edit_link" element

  @javascript
  Scenario: Viewing not applicable suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I follow "edit"
    And I check "not applicable"
    And I press "Save"
    And I go to the last encounter note edit page
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    And I should see an ".edit_link" element

  @javascript
  Scenario: Viewing accepted suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    When I select "Accepted" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Accepted" selected
    And I should not see an ".edit_link" element

  @javascript
  Scenario: Changing status for unknown suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                    |
      | Looking good. Not too sure about KPS though. |
    When I go to the last encounter note edit page
    And I select "Rejected" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And I should see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I select "Accepted" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I select "Needs review" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for not applicable suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                    |
      | Looking good. Not too sure about KPS though. |
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I follow "edit"
    And I check "not applicable"
    And I press "Save"
    And I go to the last encounter note edit page
    And I select "Rejected" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And I should see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I select "Accepted" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I select "Needs review" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for a suggestion
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text               |
      | Looking good. KPS: 100. |
    And I go to the last encounter note edit page
    And I select "Rejected" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then I should see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And I go to the last encounter note edit page
    And I select "Accepted" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    And I go to the last encounter note edit page
    And I select "Needs review" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I should not see an ".edit_link" element
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for multiple sugestions
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                                      |
      | Looking good. KPS: 100.  On second thought make that KPS: 50.  |
    And I go to the last encounter note edit page
    And I select "Rejected" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the last ".edit_abstractor_suggestion" should have "Needs review" selected
    And I should not see an ".edit_link" element
    When I select "Accepted" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the last ".edit_abstractor_suggestion" should have "Rejected" selected
    And I should not see an ".edit_link" element
    When I select "Accepted" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the last ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "50% - Requires considerable assistance and frequent medical care."
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    And I should not see an ".edit_link" element
    When I select "Needs review" from "#abstractor_suggestion_abstractor_suggestion_status_id" in the last ".edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Needs review" selected
    And I should not see an ".edit_link" element

  @javascript
  Scenario: Viewing source for suggestion with source and match value
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                            |
      |The patient is looking good.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within "span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "The patient is looking good.  KPS: 100"
    And ".ui-dialog-content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: Viewing source for suggestion with source and no match value
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                |
      |Hello, your KPS is something. Have a great day!|
    When I go to the last encounter note edit page
    And I click within "span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is something. Have a great day!"
    And ".ui-dialog-content" should equal highlighted text "KPS"

  @javascript
  Scenario: Viewing source for unknown suggestion without match value
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                |
      |This is your physical assessment. Have a great day!|
    When I go to the last encounter note edit page
    And I click within "span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "This is your physical assessment. Have a great day!"
    And ".ui-dialog-content" should not equal highlighted text "KPS"

  @javascript
  Scenario: Viewing source for suggestion with source and multiple match values
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                                                  |
      |Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%!|
    And I go to the last encounter note edit page
    And I click on "img" within the first "span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%!"
    And ".ui-dialog-content" should equal highlighted text "Hello, your KPS is 100%."
    And ".ui-dialog-content" should not equal highlighted text "Yes, KPS is 100%!"
    When I go to the last encounter note edit page
    And  I click on "img" within the last "span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%. Have a great day!"
    And ".ui-dialog-content" should not equal highlighted text "Hello, your KPS is 100%."
    And ".ui-dialog-content" should equal highlighted text "Yes, KPS is 100%!"

  @javascript
  Scenario: Accessing abstraction edit form
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text              |
      |Hello, your KPS is 100%.|
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I wait for the ajax request to finish
    Then the element "select.combobox" should be hidden
    And I should not see an ".edit_link" element
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "select.combobox"
    And "select.combobox" in the first ".abstractor_abstraction" should have options "100% - Normal; no complaints; no evidence of disease., 90% - Able to carry on normal activity; minor signs or symptoms of disease., 80% - Normal activity with effort; some signs or symptoms of disease."
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "input#abstractor_abstraction_not_applicable"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "input#abstractor_abstraction_unknown"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    Then ".abstractor_abstraction_edit input.positive" should contain "Save"
    And I should see "Cancel"
    When I check "input#abstractor_abstraction_unknown" within the first ".abstractor_abstraction"
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    When I check "input#abstractor_abstraction_not_applicable" within the first ".abstractor_abstraction"
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    When I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    Then "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    And I click on "span.abstractor_abstraction_source_tooltip_img" within the first ".edit_abstractor_abstraction"
    And I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%."
    When I follow "Cancel"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"

  @javascript
  Scenario: User creating unknown abstraction
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text              |
      |Hello, your KPS is 100%.|
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I check "input#abstractor_abstraction_unknown" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    When I click on ".edit_link" within the first ".abstractor_abstraction"
    Then "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should be checked
    And "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked

  @javascript
  Scenario: User creating unknown abstraction when unknown suggestion exists
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                 |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I check "input#abstractor_abstraction_unknown" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Accepted" selected
    And I should not see an ".edit_link" element

  @javascript
  Scenario: User creating not applicable abstraction
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                  |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I check "input#abstractor_abstraction_not_applicable" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    When I click on ".edit_link" within the first ".abstractor_abstraction"
    Then "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should be checked
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked

  @javascript
  Scenario: User creating abstraction
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                 |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see an ".edit_link" element
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Rejected" selected
    When I click on ".edit_link" within the first ".abstractor_abstraction"
    Then "select.combobox" in the first ".abstractor_abstraction" should have "100% - Normal; no complaints; no evidence of disease." selected
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    When I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."

  @javascript
  Scenario: User creating abstraction when matching suggestion exists
    Given encounter note abstraction schema is set
    And encounter notes with the following information exist
      | Note Text                            |
      | Hello, you look good to me. KPS: 100 |
    And I go to the last encounter note edit page
    And I select "Rejected" from "abstractor_suggestion_abstractor_suggestion_status_id"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then "#abstractor_suggestion_abstractor_suggestion_status_id" in the first ".edit_abstractor_suggestion" should have "Accepted" selected