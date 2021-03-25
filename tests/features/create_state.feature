Feature: Create state records

  Scenario: I can create a state record

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                       |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the set "10032021_1130" should contain:
      | key             |
      | dd_filename.txt |
    And the response code should be "201"
    And the response should be:
      """
      {
        "state": "started",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130"
      }
      """

  Scenario: If I set the state to errored I can provide error_info
    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "errored",
        "batch": "10032021_1130",
        "error_info": "It exploded real bad"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                                                             |
      | dd_filename.txt | {"state": "errored", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "error_info": "It exploded real bad"} |
    And the set "10032021_1130" should contain:
      | key             |
      | dd_filename.txt |
    And the response code should be "201"
    And the response should be:
      """
      {
        "state": "errored",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "error_info": "It exploded real bad"
      }
      """

  Scenario: If I set the state to anything other than errrored I cannot provide error_info
    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "batch": "10032021_1130",
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

  Scenario: I cannot create a state record without a payload

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" without a payload
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Invalid post request"
      }
      """

  Scenario: I cannot create a state record with an empty payload

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {}
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """


  Scenario: I cannot create a state record without a batch

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """

  Scenario: I cannot create a state record without a state

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """

  Scenario: You cannot create a state record for a file that already exists

    Given redis contains:
      | key             | value                                                           |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00"} |
    And the current time is "2021-03-20 19:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key             | value                                                           |
      | dd_filename.txt | {"state": "started", "updated_at": "2021-03-19T12:45:20+00:00"} |
    Then the response code should be "409"
    And the response should be:
      """
      {
        "error": "Resource already exists"
      }
      """

  Scenario: State must be valid

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "invalid",
        "batch": "10032021_1130"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "State 'invalid' is invalid, valid states are [inactive, started, generated, in_staging, encrypted, in_nifi_bucket, nifi_notified, in_arc, errored]"
      }
      """
