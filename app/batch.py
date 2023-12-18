from client.blaise_dds.kind import DATASTORE_KIND
from flask import Blueprint, current_app, jsonify

from app.utils import api_error

batch = Blueprint("batch", __name__, url_prefix="/v1/batch")


@batch.route("", methods=["GET"])
def get_bactches():
    batch = []
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    result = list(query.fetch())
    print(f"EL'S DEBUG: result: {result}")

    if len(result) == 0:
        print("No result is returned")
        print("EL'S DEBUG: No result is returned")
    else:
        batch.extend(result)

    foo = jsonify(batch), 200
    print(f"EL'S DEBUG: jsonify(batch): {foo}")

    return jsonify(batch), 200


@batch.route("/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    key = current_app.datastore_client.key(DATASTORE_KIND, batch_name)
    query = current_app.datastore_client.get(key)
    batch = list(query.items())

    if len(batch) == 0:
        return api_error("Batch does not exist", 404)    

    return jsonify(batch), 200
