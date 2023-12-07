Feature: Create state records

  Scenario: I can create a state record

    Given the current time is "2021-03-19 12:45:20"
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
        "updated_at": "2021-03-19T12:45:20+00:00",
      }
      """