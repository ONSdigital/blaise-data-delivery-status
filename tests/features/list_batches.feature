Feature: Get list of all batches

  Scenario: I can get a list of all batches

    Given redis contains:
      | key                    | value                                                                                                                        |
      | dd_filename.txt        | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032021_1130"} |
      | dd_unique_filename.txt | {"state": "starting", "updated_at": "2021-03-19T12:45:20+00:00", "dd_filename": "dd_filename.txt", "batch": "10032022_8888"} |
    And the redis set "10032021_1130" contains:
      | key             |
      | dd_filename.txt |
    And the redis set "10032022_8888" contains:
      | key                    |
      | dd_unique_filename.txt |
    When I GET "/v1/batch"
    Then the response code should be "200"
    And the response should be:
      """
      [
        "10032021_1130",
        "10032022_8888"
      ]
      """
