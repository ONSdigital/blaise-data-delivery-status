Feature: Get state records

  Scenario: I can get a specific state record


    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    When I GET "/v1/state/dd_filename.txt"
    Then the response code should be "200"
    And the response should be:
      """
      {
        "state": "starting",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130"
      }
      """

  Scenario: Attempt to get a specific state record that does not exist


    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    When I GET "/v1/state/dd_bacon.txt"
    Then the response code should be "404"
    And the response should be:
      """
      {
        "error": "State record does not exist"
      }
      """
