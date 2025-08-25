from flask import Blueprint, current_app, jsonify

from app.models import DATASTORE_KIND
from app.utils import api_error

batch = Blueprint("batch", __name__, url_prefix="/v1/batch")


@batch.route("", methods=["GET"])
def get_batches():
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    query.distinct_on = ["batch"]
    query.projection = ["batch"]

    batches = {entity["batch"] for entity in query.fetch()}
    return jsonify(sorted(list(batches))), 200


@batch.route("/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    query = current_app.datastore_client.query(kind=DATASTORE_KIND)
    query.add_filter("batch", "=", batch_name)
    result = list(query.fetch())

    if not result:
        return api_error("Batch does not exist", 404)

    return jsonify(result), 200
