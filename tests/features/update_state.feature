Feature: Update state records

  Scenario: I can update a state record

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "in_arc"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                      |
      | dd_filename.txt | {"state": "in_arc", "updated_at": "2021-03-20T19:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "200"
    And the response should be:
      """
      {
        "state": "in_arc",
        "updated_at": "2021-03-20T19:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130"
      }
      """

  Scenario: If I set the state to errored I can provide error_info
    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "errored",
        "error_info": "It exploded real bad"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                                                             |
      | dd_filename.txt | {"state": "errored", "updated_at": "2021-03-20T19:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "error_info": "It exploded real bad"} |
    And the response code should be "200"
    And the response should be:
      """
      {
        "state": "errored",
        "updated_at": "2021-03-20T19:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "error_info": "It exploded real bad"
      }
      """

  Scenario: If I set the state to anything other than errrored I cannot provide error_info
    Given redis contains:
      | key | value |
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "error_info": "It exploded real bad"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "You can only provide 'error_info' if the state is 'errored'"
      }
      """

  Scenario: I cannot update a state record if the state is unchanged

    Given redis contains:
      | key             | value                                                                                                                       |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                       |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "State is unchanged"
      }
      """

  Scenario: I cannot update a state record with an empty payload

    Given redis contains:
      | key             | value                                                                                                                       |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {}
      """
    Then redis should contain:
      | key             | value                                                                                                                       |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state'"
      }
      """

  Scenario: I cannot update a state record if the record does not exist

    Given redis contains:
      | key | value |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "in_arc"
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

  Scenario: State must be valid

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "finished"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "State 'finished' is invalid, valid states are [inactive, started, generated, in_staging, encrypted, in_nifi_bucket, nifi_notified, in_arc, errored]"
      }
      """
