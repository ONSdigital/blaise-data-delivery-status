from client.blaise_dds.kind import DATASTORE_KIND
from flask import Blueprint, current_app, jsonify

from app.utils import api_error

batch = Blueprint("batch", __name__, url_prefix="/v1/batch")


@batch.route("", methods=["GET"])
def get_batches():
    batch = []
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    result = list(query.fetch())

    for entity in result:
        batch.append(entity['batch'])

    return jsonify(batch), 200


@batch.route("/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    batch = []
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    query.add_filter('batch', '=', batch_name)
    result = list(query.fetch())

    if len(result) == 0:
        return api_error("Batch does not exist", 404)

    for entity in result:
        batch.append(entity)

    return jsonify(batch), 200
