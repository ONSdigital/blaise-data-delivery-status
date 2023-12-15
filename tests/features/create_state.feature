Feature: Create state records

  Scenario: I can create a state record

    Given Datastore contains:
      """
      []
      """
    # TODO: Continue to use freezegun or use another alternative - or even remove the frozen time entirely
    # NOTE: freezegun seems to work with Google Datastore when the time is very recent, i.e. present time or a few hours later
    And the current time is "2023-12-15 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then Datastore should contain:
      """
        [
          {
            "alerted": false,
            "batch": "10032021_1130",
            "dd_filename": "dd_filename.txt",
            "state": "started",
            "updated_at": "2023-12-15T12:45:20+00:00"
          }
        ]
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

  # Scenario: If I set the state to errored I can provide error_info
  #   Given Datastore contains:
  #     """
  #     []
  #     """
  #   # TODO: To keep or remove depending on whether we still need freezegun
  #   # And the current time is "2021-03-19 12:45:20"
  #   When I POST to "/v1/state/dd_filename.txt" with the payload:
  #     """
  #     {
  #       "state": "errored",
  #       "batch": "10032021_1130",
  #       "error_info": "It exploded real bad"
  #     }
  #     """
  #   Then Datastore should contain:
  #     """
  #     [
  #       {
  #         "state": "errored",
  #         "updated_at": "2021-03-19T12:45:20+00:00",
  #         "dd_filename": "dd_filename.txt",
  #         "batch": "10032021_1130",
  #         "alerted": false,
  #         "error_info": "It exploded real bad"
  #       }
  #     ]
  #     """
  #   And the response code should be "201"
  #   And the response should be:
  #     """
  #     {
  #       "state": "errored",
  #       "updated_at": "2021-03-19T12:45:20+00:00",
  #       "dd_filename": "dd_filename.txt",
  #       "batch": "10032021_1130",
  #       "alerted": false,
  #       "error_info": "It exploded real bad"
  #     }
  #     """