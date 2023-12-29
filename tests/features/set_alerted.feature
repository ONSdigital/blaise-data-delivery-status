Feature: I can mark a state record as alerted

  Scenario: I can set a state record to alerted

    Given Datastore contains
      """
      [
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130"
      }
      ]
      """
    And the current time is set
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload
      """
      {
        "alerted": true
      }
      """
    Then Datastore should contain
      """
        {
            "state": "starting",
            "dd_filename": "dd_filename.txt",
            "batch": "10032021_1130",
            "alerted": true
        }
      """
    Then the response code should be "200"
    And the response should be
      """
      {
        "state": "starting",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": true
      }
      """

  Scenario: I can set a state record to not alerted

    Given Datastore contains
      """
      [
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": true
      }
      ]
      """
    And the current time is set
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload
      """
      {
        "alerted": false
      }
      """
    Then Datastore should contain
      """
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": false
      }
      """
    Then the response code should be "200"
    And the response should be
      """
      {
        "state": "starting",
        "dd_filename": "dd_filename.txt",
        "batch": "10032021_1130",
        "alerted": false
      }
      """


  Scenario: Alerted must be set

    Given Datastore contains
      """
      [
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": true
      }
      ]
      """
    And the current time is set
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload
      """
      {}
      """
    Then Datastore should contain
      """
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": true
      }
      """
    Then the response code should be "400"
    And the response should be
      """
      {
        "error": "Request did not include 'alerted'"
      }
      """


  Scenario: Alerted must be a bool

    Given Datastore contains
      """
      [
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": true
      }
      ]
      """
    And the current time is set
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload
      """
      {
        "alerted": "foo"
      }
      """
    Then Datastore should contain
      """
      {
          "state": "starting",
          "dd_filename": "dd_filename.txt",
          "batch": "10032021_1130",
          "alerted": true
      }
      """
    Then the response code should be "400"
    And the response should be
      """
      {
        "error": "Alerted must be a boolean"
      }
      """

  Scenario: I cannot update a state record if the record does not exist

    Given Datastore contains
      """
      []
      """
    And the current time is set
    When I PATCH to "/v1/state/dd_filename.txt/alerted" with the payload
      """
      {
        "alerted": false
      }
      """
    Then Datastore should not contain
      """
      []
      """
    Then the response code should be "404"
    And the response should be
      """
      {
        "error": "State record does not exist"
      }
      """