Feature: Create state records

  Scenario: I can create a state record

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "batch": "10032021_1130",
        "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "service_name": "data delivery"} |
    And the set "10032021_1130" should contain:
      | key             |
      | dd_filename.txt |
    And the response code should be "200"
    And the response should be:
      """
      {
        "state": "starting",
        "updated_at": "2021-03-19T12:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "service_name": "data delivery"
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
        "error": "Request did not include 'state' or 'batch' or 'service_name'"
      }
      """


  Scenario: I cannot create a state record without a batch

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch' or 'service_name'"
      }
      """

  Scenario: I cannot create a state record without a state

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "batch": "10032021_1130",
        "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch' or 'service_name'"
      }
      """

      Scenario: I cannot create a state record without a service name

    Given redis contains:
      | key | value |
    And the current time is "2021-03-19 12:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "batch": "10032021_1130",
        "state": "starting"
      }
      """
    Then redis should contain:
      | key | value |
    And the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'batch' or 'service_name'"
      }
      """

  Scenario: You can create a state record for a file that already exists

    Given redis contains:
      | key             | value                                                            |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00"} |
    And the current time is "2021-03-20 19:45:20"
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "batch": "10032021_1130",
        "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key             | value                                                            |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00"} |
    Then the response code should be "409"
    And the response should be:
      """
      {
        "error": "Resource already exists"
      }
      """
