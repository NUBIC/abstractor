Feature: Editing surgery
  User should be able to edit surgery information

  @javascript
  Scenario: User editing an abstraction with indirect sources
    Given abstraction schemas are set
    And surgeries with the following information exist
      | Surgery Case ID | Surgery Case Number | Patient ID |
      |      100        | OR-123              |     1      |
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             |
      | Hello, you look suspicious.         |      1     | 2/1/2014 |  456             |
      | Hello, you look better than before. |      2     | 5/1/2014 |  789             |
    And surgical procedure reports with the following information exist
      | Note Text                           | Patient ID | Date      | Reference Number |
      | Surgery went well.                  |      1     | 1/1/2013  | 111              |
      | Surgery went not so well.           |      1     | 2/1/2013  | 222              |
      | Hello, you look better than before. |      2     | 5/1/2013  | 333              |
    When I go to the last surgery edit page
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    And I select "123 (2014-01-01)" from ".indirect_source_list" in the first ".indirect_source"
    And I wait for the ajax request to finish
    Then ".indirect_source_text" in the first ".indirect_source" should contain text "Hello, you look good to me."
    When I press "Save"
    And I go to the last surgery edit page
    And I click on ".edit_link" within the first ".abstractor_abstraction"
    Then ".indirect_source_list" in the first ".indirect_source" should have "123 (2014-01-01)" selected