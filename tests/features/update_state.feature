Feature: Update state records

  Scenario: I can update a state record

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "service_name": "data delivery"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "finished",
        "service_name": "nifi encrypt"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "finished", "updated_at": "2021-03-20T19:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "service_name": "nifi encrypt"} |
    Then the response code should be "200"
    And the response should be:
      """
      {
        "state": "finished",
        "updated_at": "2021-03-20T19:45:20+00:00",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "service_name": "nifi encrypt"
      }
      """

  Scenario: I cannot update a state record if the state is unchanged

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "starting",
        "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "State is unchanged"
      }
      """

  Scenario: I cannot update a state record with an empty payload

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {}
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'service_name'"
      }
      """

  Scenario: I cannot update a state record if the no state value is provided

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
      "service_name": "data delivery"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'service_name'"
      }
      """

  Scenario: I cannot update a state record if the no service_name value is provided

    Given redis contains:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "service_name": "data delivery"} |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "something happened"
      }
      """
    Then redis should contain:
      | key             | value                                                                                                                        |
      | dd_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130", "service_name": "data delivery"} |
    Then the response code should be "400"
    And the response should be:
      """
      {
        "error": "Request did not include 'state' or 'service_name'"
      }
      """

  Scenario: I cannot update a state record if the record does not exist

    Given redis contains:
      | key | value |
    And the current time is "2021-03-20 19:45:20"
    When I PATCH to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "finished",
        "service_name": "data delivery"
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
