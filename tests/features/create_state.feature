Feature: Create state records

  Scenario: I can create a state record

    Given redis contains:
      | key | value |
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key             | value                 |
      | dd_filename.txt | {"state": "starting"} |
    And the set "10032021_1130" should contain:
      | key             |
      | dd_filename.txt |
    And the response should contain:
      """
      bantz
      """