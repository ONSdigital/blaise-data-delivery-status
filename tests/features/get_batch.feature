Feature: Get batch details

  Scenario: I can get all states within a batch

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
                "state": "in_arc",
                "dd_filename": "dd2_filename.txt",
                "batch": "10032021_1130"
            }
            ]
            """
   And the Datastore set "10032021_1130" contains
            """
            [
              "dd_filename.txt",
              "dd2_filename.txt"
            ]
            """
    When I GET "/v1/batch/10032021_1130"
    Then the response code should be "200"
    And the response list should be
      """
      [
        {
            "batch": "10032021_1130",
            "dd_filename": "dd2_filename.txt",
            "state": "in_arc"
        },
        {
            "batch": "10032021_1130",
            "dd_filename": "dd_filename.txt",
            "state": "starting"
        }
      ]
      """

  Scenario: I cannot get batches that do not exist

    Given the current time is set
    And Datastore contains
      """
      []
      """
    When I GET "/v1/batch/10032022_0230"
    Then the response code should be "404"
    And the response should be
      """
      {
        "error": "Batch does not exist"
      }
      """