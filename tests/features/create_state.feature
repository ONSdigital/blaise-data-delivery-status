Feature: Create state records

  Scenario: I can create a state record

    Given Datastore contains:
      """
      []
      """
    And the current time is "2023-12-15 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then Datastore should contain
      """
      {
        "alerted": false,
        "batch": "10032021_1130",
        "dd_filename": "dd_filename.txt",
        "state": "started",
        "updated_at": "2023-12-15T12:45:20+00:00"
      }
      """
    And the response code should be "201"
    And the response should be:
      """
      {
        "state": "started",
        "updated_at": "2023-12-15T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false
      }
      """