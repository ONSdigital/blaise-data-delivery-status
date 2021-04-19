Feature: I can mark a state record as alerted

  Scenario: I can set a state record to alerted

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload:
      """
      {
        "alerted": true
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    Then the response code should be "200"
    And the response should be:
      """
      {
        "state": "starting",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": true
      }
      """

  Scenario: I can set a state record to not alerted

    Given redis contains:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload:
      """
      {
        "alerted": false
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                                          |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": false} |
    Then the response code should be "200"
    And the response should be:
      """
      {
        "state": "starting",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false
      }
      """

  Scenario: Alerted must be set

    Given redis contains:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload:
      """
      {}
      """
    Then redis should contain:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'alerted'"
      }
      """

  Scenario: Alerted must be a bool

    Given redis contains:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload:
      """
      {
        "alerted": "foo"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                                         |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "alerted": true} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Alerted must be a boolean"
      }
      """

  Scenario: I cannot update a state record if the record does not exist

    Given redis contains:
      | key | value |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload:
      """
      {
        "alerted": false
      }
      """
    Then redis should contain:
      | key | value |
    Then the response code should be "404"
    And the response should be:
      """
      {
        "error": "State record does not exist"
      }
      """
