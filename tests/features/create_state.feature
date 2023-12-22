Feature: Create state records

  Scenario: I can create a state record
    Given Datastore contains
      """
      []
      """ 
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then the response code should be "201"
    And the response should be
      """
      {
        "state": "started",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false
      }
      """
    And Datastore should contain
      """
          {
            "alerted": false,
            "batch": "10032021_1130",
            "dd_filename": "dd_filename.txt",
            "state": "started"
          }
      """


  Scenario: If I set the state to errored I can provide error_info
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "errored",
        "batch": "10032021_1130",
        "error_info": "It exploded real bad"
      }
      """
    Then the response code should be "201"
    And the response should be
      """
      {
        "state": "errored",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false,
        "error_info": "It exploded real bad"
      }
      """
    And Datastore should contain
      """
        {
          "state": "errored",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": false,
          "error_info": "It exploded real bad"
        }
      """

  Scenario: If I set the state to anything other than errored I cannot provide error_info
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "started",
        "batch": "10032021_1130",
        "error_info": "It exploded real bad"
      }
      """
    Then Datastore should not contain
      """
      []
      """
    And the response code should be "400"
    And the response should be
      """
      {
        "error": "You can only provide 'error_info' if the state is 'errored'"
      }
      """

  Scenario: I cannot create a state record without a payload
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" without a payload
    Then Datastore should not contain
      """
      []
      """
    And the response code should be "400"
    And the response should be
      """
      {
        "error": "Invalid post request"
      }
      """

  Scenario: I cannot create a state record with an empty payload
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {}
      """
    Then Datastore should not contain
      """
      []
      """
    And the response code should be "400"
    And the response should be
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """

  Scenario: I cannot create a state record without a batch
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "started"
      }
      """
    Then Datastore should not contain
      """
      []
      """
    And the response code should be "400"
    And the response should be
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """

  Scenario: I cannot create a state record without a state
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "batch": "10032021_1130"
      }
      """
    Then Datastore should not contain
      """
      []
      """
    And the response code should be "400"
    And the response should be
      """
      {
        "error": "Request did not include 'state' or 'batch'"
      }
      """

  Scenario: You cannot create a state record for a file that already exists
    Given Datastore contains
      """
      [
        {
          "state": "started",
          "dd_filename": "dd_filename.txt"
        }
      ]
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload
      """
      {
        "state": "started",
        "batch": "10032021_1130"
      }
      """
    Then the response code should be "409"
    And the response should be
      """
      {
        "error": "Resource already exists"
      }
      """
    And Datastore should contain
      """
        {
          "state": "started",
          "dd_filename": "dd_filename.txt"
        }
      """


  Scenario: State must be valid
    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I POST to "/v1/state/dd_filename.txt" with the payload:
      """
      {
        "state": "invalid",
        "batch": "10032021_1130"
      }
      """
    Then the response code should be "400"
    And the response should be
      """
      {
        "error": "State 'invalid' is invalid, valid states are [inactive, started, generated, in_staging, encrypted, in_nifi_bucket, nifi_notified, in_arc, errored]"
      }
      """
    And Datastore should not contain
      """
      []
      """