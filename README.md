# Blaise Data Delivery Status

[![codecov](https://codecov.io/gh/ONSdigital/blaise-data-delivery-status/branch/main/graph/badge.svg)](https://codecov.io/gh/ONSdigital/blaise-data-delivery-status)
[![CI status](https://github.com/ONSdigital/blaise-data-delivery-status/workflows/Test%20coverage%20report/badge.svg)](https://github.com/ONSdigital/blaise-data-delivery-status/workflows/Test%20coverage%20report/badge.svg)
<img src="https://img.shields.io/github/release/ONSdigital/blaise-data-delivery-status.svg?style=flat-square" alt="Nisra Case Mover release verison">
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/ONSdigital/blaise-data-delivery-status.svg)](https://github.com/ONSdigital/blaise-data-delivery-status/pulls)
[![Github last commit](https://img.shields.io/github/last-commit/ONSdigital/blaise-data-delivery-status.svg)](https://github.com/ONSdigital/blaise-data-delivery-status/commits)
[![Github contributors](https://img.shields.io/github/contributors/ONSdigital/blaise-data-delivery-status.svg)](https://github.com/ONSdigital/blaise-data-delivery-status/graphs/contributors)

A simple API that can be used to track the status of a data delivery process

## Batch Names

The Data Delivery Dashboard gets the time and date from the batch name. As a result, the batch name format is important.
Batch names are formatted as follows:

`TLA_DDMMYYYY_HHMMSS`

Where:
- `TLA` is the three-letter acronym for the survey
- `DDMMYYYY` is the date in the format day, month, year
- `HHMMSS` is the time in the format hour, minute, second

## States

**Note**: The latest state we can currently get is `in_arc` we do not call this `finished` because there is still
some processing that needs to happen in NiFi to copy the files to the final destination. At present, we have no way of
knowing if this has happened. If a data delivery file is in the `in_arc` state we can assume that we need to contact
CATD for more insight if any issues are reported.

**Note**: If we do not receive a receipt within 30 minutes of a message being in the `nifi_notified` state, we expect
any consumers of this API to flag it as an issue.

**Note**: If you update the state to `errored` you should also update the record with `error_info` to give any consumers
details about what has errored.

| State          | Description                                                                                                              |
|----------------|--------------------------------------------------------------------------------------------------------------------------|
| inactive       | The data delivery instrument has no active survey days, a data delivery file will not be generated.                      |
| started        | The data delivery process has found an instrument with active survey days                                                |
| generated      | The data delivery process has generated the required files                                                               |
| in_staging     | The data delivery files have been copied to the staging bucket  ready for encryption                                     |
| encrypted      | The data delivery files have been encrypted and are ready for NiFi                                                       |
| in_nifi_bucket | The data delivery files are in the NiFi bucket                                                                           |
| nifi_notified  | NiFi has been notified that we have files to ingest                                                                      |
| in_arc         | NiFi has copied the files to ARC (on prem) and sent a receipt                                                            |
| errored        | An error has occured processing the file (error receipt from NiFi for example)                                           |

## Endpoints

- [Create state](#create-state)
- [Update state](#update-state)
- [Get all batches](#get-all-batches)
- [Get all states in a batch](#get-all-states-in-a-batch)

### Create state

This can only be run to create a new state record, it is expected you would do this in the `started` state.

**Required Parameters**:

| Name         | Description                                                                                                                                                                                                                           |
|--------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| state        | The initial state of record, usually `started`                                                                                                                                                                                        |
| batch        | What batch is the record part of, this should relate to a scheduled "run" of data delivery, for OPN this would typically be the date followed by 1130, or 230, we use this to return all data delivery files for a paricular schedule |


**Request**:

```sh
curl localhost:5008/v1/state/dd_filename.txt \
 -X POST \
  -H "Content-type: application/json" \
  -d '{
    "state": "started",
    "batch": "DST_10032021_113034"
  }'
```

**Response**:

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "state": "started",
  "updated_at": "2021-03-19T12:45:20+00:00",
  "dd_filename": "dd_filename.txt",
  "batch": "DST_10032021_113034",
  "service_name": "data delivery",
  "alerted": false
}
```

### Update state

This can only used to update an existing state record.

**Required Parameters**:

| Name       | Description                                                                                                                                                                            |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| state      | The updated state of record.                                                                                                                                                           |
| error_info | This parameter is **required** when the state is `errored`, any other state **will not allow** this parameter. Provide additional information for what part of the process has failed. |

**Request**:

```sh
curl localhost:5008/v1/state/dd_filename.txt \
 -X PATCH \
  -H "Content-type: application/json" \
  -d '{
    "state": "in_staging"
  }'
```

**Response**:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "state": "in_staging",
  "updated_at": "2021-03-19T13:30:20+00:00",
  "dd_filename": "dd_filename.txt",
  "batch": "DST_10032021_113034",
  "service_name": "data delivery",
  "alerted": false
}
```

### Set alerted

This can only used to update an existing state record.

**Required Parameters**:

| Name    | Description                                                                                                       |
|---------|-------------------------------------------------------------------------------------------------------------------|
| alerted | `true` for this record has already been alerted in its current state, defaults to `false` when a state is updated |


**Request**:

```sh
curl localhost:5008/v1/state/dd_filename.txt \
 -X PATCH \
  -H "Content-type: application/json" \
  -d '{
    "alerted": "true"
  }'
```

**Response**:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "state": "in_staging",
  "updated_at": "2021-03-19T13:30:20+00:00",
  "dd_filename": "dd_filename.txt",
  "batch": "DST_10032021_113034",
  "service_name": "data delivery",
  "alerted": true
}
```

### Get all batches

Retrieve a list of all batches.

**Request**:

```sh
curl localhost:5008/v1/batch \
 -X GET \
  -H "Content-type: application/json"
```

**Response**:

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  "DST_10032021_113034",
  "DST_01022022_120001",
  "DST_11122023_120015"
]
```

### Get all states in a batch

Get a list of all the state records with a given batch.

**Request**:

```sh
curl localhost:5008/v1/batch/DST_10032021_113034 \
 -X GET \
  -H "Content-type: application/json"
```

**Response**:

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "batch":"DST_10032021_113034",
    "dd_filename":"dd_OPN2102R_24032021_165033.zip",
    "state":"Started",
    "updated_at":"2021-03-24T16:50:35+00:00",
    "alerted": false
  },
  {
    "batch":"DST_10032021_113034",
    "dd_filename":"dd_OPN2101W_24032021_165033.zip",
    "state":"in_staging",
    "updated_at":"2021-03-24T16:50:35+00:00",
    "alerted": false
  }
]
```
## Local Development
#### Prerequisites
- [GCP Cloud SDK](https://cloud.google.com/sdk/docs/install-sdk)
- [Python](https://www.python.org/downloads/)
- [Poetry](https://python-poetry.org/docs/)


This repository uses **Python 3.9** and **Poetry**.

1.  [Clone the repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) using your preferred method.

2.  Connect to a Datastore instance, check and follow [Google Cloud Datastore](#google-cloud-datastore).

3.  Ensure you are using **Python 3.9** and install the dependencies by running:
    ```shell
    poetry install
    ```

5.  To start the Flask app, run:
    ```shell
    poetry run python main.py
    ```

6. Once the app is running, it should now be able to receive and respond to requests.

## Google Cloud Datastore
This repository uses Google Cloud Datastore, a fully-managed NoSQL database. When setting up the service locally, you have two options:
  1.  [Configure service to connect to a real Datastore instance on GCP.](#setup-cloud-sdk)
  2.  [Install Datastore Emulator and setup a local Datastore instance.](#setup-datastore-emulator)

### Setup Cloud SDK
Ensure you have installed ```gcloud``` CLI.

1. Authenticate with GCP:
    ```shell
    gcloud auth login
    ```

2.  Set the GCP project that hosts your Datastore instance:
    ```shell
    gcloud config set project ons-blaise-v2-dev-<sandbox-suffix>
    ```

3. Google Cloud Client Libraries typically require authentication to function properly, see [documentation](https://googleapis.dev/python/google-api-core/latest/auth.html).
For local development, the easiest way to authenticate is by running:
    ```shell
    gcloud auth application-default login
    ```

### Setup Datastore Emulator
Google provides a Datastore Emulator that allows you to host a local Datastore instance.
To configure the Datastore client library to use this local Datastore instance, we will need an ```.env``` file with the following variables:
 
| Environment Variable | Description |
|--|--|
| DATASTORE_DATASET | The ID of your Google Cloud Datastore dataset. It's used by the client to identify which dataset to interact with. |
| DATASTORE_EMULATOR_HOST | This is the address of the Datastore emulator if you're using one for local development or testing. The emulator simulates the real Datastore service. The value is typically in the format of `hostname:port` |
| DATASTORE_EMULATOR_HOST_PATH | The full path to the Datastore emulator, including the `/datastore` endpoint. It's used by the client to send requests to the emulator. |
| DATASTORE_HOST | The base URL of the Datastore service. If you're using an emulator, it should point to the emulator's address. If you're interacting with the real Datastore service, it should default to `https://datastore.googleapis.com`. |
| DATASTORE_PROJECT_ID | The ID of your Google Cloud project. It's used by the client to identify which project's Datastore to interact with. |

Example .env file:
```shell
DATASTORE_DATASET=test-dataset
DATASTORE_EMULATOR_HOST=localhost:8081
DATASTORE_EMULATOR_HOST_PATH=localhost:8081/datastore
DATASTORE_HOST=http://localhost:8081
DATASTORE_PROJECT_ID=test-project
```

1.  Once you've created a ```.env``` file, install the Datastore Emulator by running:
    ```shell
    make install-datastore-emulator
    ```

2.  Start running the Datastore Emulator by running the following:
    ```shell
    gcloud beta emulators datastore start --no-store-on-disk
    ```
    **NB:** Running this command instead of ```make start-datastore-emulator``` allows you to easily terminate the local Datastore Emulator. For more info, see the [docs](https://cloud.google.com/datastore/docs/tools/datastore-emulator).

### Makefile

A `Makefile` is included with some useful tasks to help with development.

Running `make help` will list all available commands.

### Run Tests

You will need the [Google Cloud Datastore Emulator](#google-cloud-datastore) to run the full test suite.

To run the **full test suite**, including the Datastore behave tests:
```shell
make test
```
  

To run the **unit tests** which do not use the Datastore emulator:
```shell
make test-unit
```


To run the **behave tests** which uses the Datastore emulator, you will need to:
1. Connect to the running Datastore Emulator, by following [Setup Datastore Emulator](#setup-datastore-emulator).

2. Run the following to start the tests:
    ```shell
    make test-behave
    ```