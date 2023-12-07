import json

from google.cloud import datastore
from behave import given, then

DATASTORE_KIND = "DDS_tests"


# TODO: This should work if it was pointing at the emulator
@then("Datastore should contain")
def step_impl(context):
    # arrange
    expected = json.loads(context.text)

    client = context.datastore_client
    query = client.query(kind=DATASTORE_KIND)
    query.add_filter("updated_at", "=", expected["updated_at"])

    # act
    result = query.fetch()

    # assert
    assert result == expected
