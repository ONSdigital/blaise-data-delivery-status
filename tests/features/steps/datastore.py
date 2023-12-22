import json
from datetime import datetime
import pytz

from google.cloud import datastore
from behave import given, then
from client.blaise_dds import DATASTORE_KIND


@given("Datastore contains")
def step_impl(context):
    print("STEP 1:", context.time)
    data = json.loads(context.text)
    if len(data) == 0:
        return None

    for item in data:
        record_entity = datastore.Entity(
            context.datastore_client.key(DATASTORE_KIND, item["dd_filename"])
        )
        record_entity.update(item)
        record_entity["updated_at"] = context.time
        print("STEP 1:", context.time)
        context.datastore_client.put(record_entity)


@then("Datastore should contain")
def step_impl(context):
    # arrange
    expected = json.loads(context.text)
    expected["updated_at"] = datetime.now(pytz.utc).replace(microsecond=0).isoformat()

    client = context.datastore_client
    query = client.query(kind=DATASTORE_KIND)
    #query.add_filter("updated_at", "=", expected["updated_at"])
    query_results = list(query.fetch())

    # act
    result = dict(list(query_results)[0]) if query_results else None

    print("EXPECTED: ", expected)
    print("RESULT: ", result)
    # assert
    assert result == expected, "Resulting Datastore data does not match expected data"


@then("Datastore should not contain")
def step_impl(context):
    # arrange
    expected = json.loads(context.text)

    client = context.datastore_client
    query = client.query(kind=DATASTORE_KIND)
    query_iter = query.fetch()

    # act
    result = dict(list(query_iter))
    # assert
    assert len(result) == 0, "Resulting Datastore data does not match expected data"
