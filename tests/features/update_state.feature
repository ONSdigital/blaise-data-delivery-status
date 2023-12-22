#Feature: Update state records
#
#  Scenario: I can update a state record
#
#    Given Datastore contains
#       """
#       [
#        {
#          "state": "starting",
#          "dd_filename": "dd_filename.txt",
#          "batch": "10032021_1130"
#        }
#        ]
#       """
#    And the current time is set
#    When I PATCH to "/v1/state/dd_filename.txt" with the payload
#      """
#      {
#        "state": "in_arc"
#      }
#      """
#    Then Datastore should contain
#    """
#      {
#        "state": "in_arc",
#        "dd_filename": "dd_filename.txt",
#        "batch": "10032021_1130",
#        "alerted": false
#      }
#      """
#    Then the response code should be "200"
#    And the response should be
#      """
#      {
#        "state": "in_arc",
#        "dd_filename": "dd_filename.txt",
#        "batch": "10032021_1130",
#        "alerted": false
#      }
#      """
#
#
#  Scenario: Updating the state defaults the "alerted" property to false
#
#    Given Datastore contains
#       """
#       [
#       {
#          "state": "starting",
#          "dd_filename": "dd_filename.txt",
#          "batch": "10032021_1130",
#          "alerted": true
#        }
#       ]
#       """
#    And the current time is set
#    When I PATCH to "/v1/state/dd_filename.txt" with the payload
#      """
#      {
#        "state": "in_arc"
#      }
#      """
#    Then Datastore should contain
#    """
#      {
#        "state": "in_arc",
#        "dd_filename": "dd_filename.txt",
#        "batch": "10032021_1130",
#        "alerted": false
#      }
#      """
#    Then the response code should be "200"
#    And the response should be
#      """
#      {
#        "state": "in_arc",
#        "dd_filename": "dd_filename.txt",
#        "batch": "10032021_1130",
#        "alerted": false
#      }
#      """
#
#  Scenario: If I set the state to errored I can provide error_info
#    Given Datastore contains
#       """
#       [
#       {
#          "state": "starting",
#          "dd_filename": "dd_filename.txt",
#          "batch": "10032021_1130"
#        }
#       ]
#       """
#    And the current time is set
#    When I PATCH to "/v1/state/dd_filename.txt" with the payload
#      """
#      {
#        "state": "errored",
#        "error_info": "It exploded real bad"
#      }
#      """
#    Then Datastore should contain
#      """
#        {
#          "state": "errored",
#          "dd_filename": "dd_filename.txt",
#          "batch": "10032021_1130",
#          "alerted": false,
#          "error_info": "It exploded real bad"
#        }
#      """
#    And the response code should be "200"
#    And the response should be
#      """
#      {
#        "state": "errored",
#        "dd_filename": "dd_filename.txt",
#        "batch": "10032021_1130",
#        "error_info": "It exploded real bad",
#        "alerted": false
#      }
#      """
#
#  Scenario: If I set the state to anything other than errored I cannot provide error_info
#
#    Given Datastore contains
#      """
#      []
#      """
#    And the current time is set
#    When I PATCH to "/v1/state/dd_filename.txt" with the payload
#      """
#      {
#        "state": "started",
#        "error_info": "It exploded real bad"
#      }
#      """
#    Then Datastore should not contain
#      """
#      []
#      """
#    And the response code should be "400"
#    And the response should be
#      """
#      {
#        "error": "You can only provide 'error_info' if the state is 'errored'"
#      }
#      """