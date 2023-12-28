from google.cloud import datastore
from behave import fixture, use_fixture
from client.blaise_dds import DATASTORE_KIND
from datetime import datetime
from app.app import app

import time
import pytz


class CustomDatastoreClient(datastore.Client):
    MAX_RETRIES = 5
    RETRY_WAIT_SECONDS = 0.2

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _get_number_of_records_in_datastore(self):
        query = self.query(kind=DATASTORE_KIND)
        count = len(list(query.fetch()))
        return count

    def wait_for_datastore_to_be_empty(self):
        retries = self.MAX_RETRIES
        while self._get_number_of_records_in_datastore() > 0:
            print("Waiting for records to be deleted")
            time.sleep(self.RETRY_WAIT_SECONDS)
            retries -= 1
            if retries < 1:
                raise Exception(
                    "Failed to clear datastore. Try restarting the DataStore emulator."
                )
            
    def _entity_is_not_available(self, key):
        return self.get(key) is None

    def wait_for_record_to_be_available(self, key_name):
        retries = self.MAX_RETRIES
        key = self.key(DATASTORE_KIND, key_name)
        while self._entity_is_not_available(key):
            print(f"Waiting for record {key} to be available")
            time.sleep(self.RETRY_WAIT_SECONDS)
            retries -= 1
            if retries < 1:
                raise Exception(f"Record {key} never became available.")

@fixture
def flaskr_client(context, *args, **kwargs):
    app.testing = True
    context.client = app.test_client()
    app.datastore_client = CustomDatastoreClient(project='test-project')
    context.datastore_client = app.datastore_client

    context.time = datetime.now(pytz.utc).replace(microsecond=0).isoformat()
    yield context.client

def before_scenario(context, _scenario):
    use_fixture(flaskr_client, context)

def after_scenario(context, _scenario):
    query = context.datastore_client.query(kind=DATASTORE_KIND)
    query_results = list(query.fetch())
    context.datastore_client.delete_multi(query_results)
    context.datastore_client.wait_for_datastore_to_be_empty()

    if hasattr(context, 'freezer'):
        context.freezer.stop()
