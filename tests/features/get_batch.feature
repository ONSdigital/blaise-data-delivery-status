Feature: Get batch details

  Scenario: I can get all states within a batch

    Given redis contains:
      | key              | value                                                                                                                         |
      | dd_filename.txt  | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"}  |
      | dd2_filename.txt | {"state": "finished", "updated_at": "2021-03-21T13:15:20+00:00", "dd_filename": "dd2_filename.txt", "batch": "10032021_1130"} |
    And the redis set "10032021_1130" contains:
      | key              |
      | dd_filename.txt  |
      | dd2_filename.txt |
    When I GET "/v1/batch/10032021_1130"
    Then the response code should be "200"
    And the response should be:
      """
      [
        {
          "batch": "10032021_1130",
          "dd_filename": "dd2_filename.txt",
          "state": "finished",
          "updated_at": "2021-03-21T13:15:20+00:00"
        },
        {
          "batch": "10032021_1130",
          "dd_filename": "dd_filename.txt",
          "state": "starting",
          "updated_at": "2021-03-19T12:45:20+00:00"
        }
      ]
      """


  Scenario: I cannot get batches that do not exist

    Given redis contains:
      | key | value |
    When I GET "/v1/batch/10032022_0230"
    Then the response code should be "404"
    And the response should be:
      """
      {
        "error": "Batch does not exist"
      }
      """
