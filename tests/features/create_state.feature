Feature: Create state records

  Scenario: I can create a state record

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key             | value                                                            |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00"} |
    And the set "10032021_1130" should contain:
      | key             |
      | dd_filename.txt |
    And the response should be:
      """
      {
        "state": "starting",
        "updated_at": "2021-03-19T12:45:20+00:00"
      }
      """
