import json

from google.cloud import datastore
from behave import given, then
from client.blaise_dds import DATASTORE_KIND

@given("redis contains")
def step_impl(context):
    for row in context.table:
        context.redis_client.set(row["key"], row["value"])


@then("Datastore should contain")
def step_impl(context):
    # arrange
    expected = json.loads(context.text)

    client = context.datastore_client
    query = client.query(kind=DATASTORE_KIND)
    query.add_filter("dd_filename", "=", expected["dd_filename"])

    # act
    result = dict(list(query.fetch())[0])
    result["updated_at"] = "2021-03-19T12:45:20+00:00"

    # assert
    assert result == expected
