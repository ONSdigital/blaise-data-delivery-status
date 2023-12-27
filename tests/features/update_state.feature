Feature: Update state records

    Scenario: I can update a state record
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
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
            """
            {
            "state": "in_arc"
            }
            """
        Then the response code should be "200"
        And the response should be
        """
            {
                "state": "in_arc",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130",
                "alerted": false
            }
        """
        And Datastore should contain
        """
            {
            "state": "in_arc",
            "dd_filename": "dd_filename.txt",
            "batch": "10032021_1130",
            "alerted": false
            }
        """

    Scenario: Updating the state defaults the "alerted" property to false
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
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
        """
            {
            "state": "in_arc"
            }
        """
        Then the response code should be "200"
        And the response should be
        """
            {
            "state": "in_arc",
            "dd_filename": "dd_filename.txt",
            "batch": "10032021_1130",
            "alerted": false
            }
        """
        And Datastore should contain
        """
            {
            "state": "in_arc",
            "dd_filename": "dd_filename.txt",
            "batch": "10032021_1130",
            "alerted": false
            }
        """

    Scenario: If I set the state to errored I can provide error_info
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
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
            """
            {
            "state": "errored",
            "error_info": "It exploded real bad"
            }
            """
        Then the response code should be "200"
        And the response should be
            """
            {
            "state": "errored",
            "dd_filename": "dd_filename.txt",
            "batch": "10032021_1130",
            "error_info": "It exploded real bad",
            "alerted": false
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
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
            """
            {
            "state": "started",
            "error_info": "It exploded real bad"
            }
            """
        Then the response code should be "400"
        And the response should be
            """
            {
            "error": "You can only provide 'error_info' if the state is 'errored'"
            }
            """
        And Datastore should not contain
            """
            []
            """

    Scenario: I cannot update a state record if the state is unchanged

        Given Datastore contains
            """
            [
            {
                "state": "started",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130"
            }
            ]
            """
        And the current time is set
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
          """
          {
            "state": "started"
          }
          """
        Then Datastore should contain
          """
            {
                "state": "started",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130"
            }
          """
        Then the response code should be "400"
        And the response should be
          """
          {
            "error": "State is unchanged"
          }
          """

    Scenario: I cannot update a state record with an empty payload

        Given Datastore contains
            """
            [
            {
                "state": "started",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130"
            }
            ]
            """
        And the current time is set
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
          """
          {}
          """
        Then Datastore should contain
          """
            {
                "state": "started",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130"
            }
          """
        Then the response code should be "400"
        And the response should be
          """
          {
            "error": "Request did not include 'state'"
          }
          """

    Scenario: I cannot update a state record if the record does not exist

        Given Datastore contains
          """
          []
          """
        And the current time is set
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
          """
          {
            "state": "in_arc"
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

    Scenario: State must be valid

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
        When I PATCH to "/v1/state/dd_filename.txt" with the payload
          """
          {
            "state": "finished"
          }
          """
        Then Datastore should contain
          """
            {
                "state": "starting",
                "dd_filename": "dd_filename.txt",
                "batch": "10032021_1130"
            }
          """
        Then the response code should be "400"
        And the response should be
          """
          {
            "error": "State 'finished' is invalid, valid states are [inactive, started, generated, in_staging, encrypted, in_nifi_bucket, nifi_notified, in_arc, errored]"
          }
          """