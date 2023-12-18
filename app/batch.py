from client.blaise_dds.kind import DATASTORE_KIND
from flask import Blueprint, current_app, jsonify

from app.utils import api_error

batch = Blueprint("batch", __name__, url_prefix="/v1/batch")


@batch.route("", methods=["GET"])
def get_batches():
    batch = []
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    result = list(query.fetch())

    if len(result) == 0:
        print("No result is returned")
        jsonify(batch), 204

    for entity in result:
        batch.append(entity['batch'])

    return jsonify(batch), 200


@batch.route("/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    print(f"EL'S DEBUG: Called get_batch()")

    key = current_app.datastore_client.key(DATASTORE_KIND, batch_name)
    print(f"EL'S DEBUG: key: {key}")

    query = current_app.datastore_client.get(key)
    print(f"EL'S DEBUG: query: {query}")

    batch = list(query.items())
    print(f"EL'S DEBUG: batch: {batch}")

    print(f"EL'S DEBUG: len(batch): {len(batch)}")
    if len(batch) == 0:
        return api_error("Batch does not exist", 404)

    print(f"EL'S DEBUG: jsonify(batch): {jsonify(batch)}")
    return jsonify(batch), 200
