Feature: Get state descriptions
  Scenario: I can get the state keys and descriptions

    Given the current time is set
    When I GET "/v1/state/descriptions"
    Then the response code should be "200"
    And the response should be
      """
      {
        "inactive": "The data delivery instrument has no active survey days, a data delivery file will not be generated.",
        "started": "The data delivery process has found an instrument with active survey days",
        "generated": "The data delivery process has generated the required files",
        "in_staging": "The data delivery files have been copied to the staging bucket ready for encryption",
        "encrypted": "The data delivery files have been encrypted and are ready for NiFi",
        "in_nifi_bucket": "The data delivery files are in the NiFi bucket",
        "nifi_notified": "NiFi has been notified that we have files to ingest",
        "in_arc": "NiFi has copied the files to ARC (on prem) and sent a receipt",
        "errored": "An error has occured processing the file (error receipt from NiFi for example)"
      }
      """