Feature: Create state records

  Scenario: I can create a state record

    Given redis contains:
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
    And the response code should be "201"
    And the response should be:
      """
      {
        "state": "started",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false
      }
      """
