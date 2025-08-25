Feature: Get list of all batches

    Scenario: I can get a list of all batches

      Given the current time is set
      And Datastore contains
              """
              [
              {
                  "state": "starting",
                  "dd_filename": "dd_filename.txt",
                  "batch": "10032021_1130"
              },
              {
                  "state": "starting",
                  "dd_filename": "dd2_filename.txt",
                  "batch": "10032022_8888"
              }
              ]
              """
      And the Datastore set "10032021_1130" contains
              """
              [
                "dd_filename.txt"
              ]
              """
      And the Datastore set "10032022_8888" contains
              """
              [
                "dd2_filename.txt"
              ]
              """
      When I GET "/v1/batch"
      Then the response code should be "200"
      And the batch list should be
        """
        [
          "10032021_1130",
          "10032022_8888"
        ]
        """


    Scenario: No batches exist

      Given Datastore contains
        """
        []
        """
      And the current time is set
      And the Datastore set "10032021_1130" contains
        """
        []
        """
      When I GET "/v1/batch"
      Then the response code should be "200"
      And the batch list should be
        """
        []
        """

    Scenario: I can get a list of all unique batches

      Given the current time is set
      And Datastore contains
              """
              [
              {
                  "state": "starting",
                  "dd_filename": "dd_filename.txt",
                  "batch": "10032021_1130"
              },
              {
                  "state": "starting",
                  "dd_filename": "dd2_filename.txt",
                  "batch": "10032021_1130"
              },
              {
                  "state": "starting",
                  "dd_filename": "dd3_filename.txt",
                  "batch": "10032022_8888"
              }
              ]
              """
      And the Datastore set "10032021_1130" contains
              """
              [
              {
                "dd_filename.txt"
              },
              {
                "dd2_filename.txt"
              }
              ]
              """
      And the Datastore set "10032022_8888" contains
              """
              [
                "dd3_filename.txt"
              ]
              """
      When I GET "/v1/batch"
      Then the response code should be "200"
      And the batch list should be
        """
        [
          "10032021_1130",
          "10032022_8888"
        ]
        """
