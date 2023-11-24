import json

from flask import Blueprint, current_app, jsonify

from app.utils import api_error

batch = Blueprint("batch", __name__, url_prefix="/v1/batch")

# TODO: Old code to be removed once the Datastore client has been setup 
# @batch.route("", methods=["GET"])
# def get_batches():
#     batch = []
#     for key in current_app.redis_client.scan_iter("batch:*"):
#         batch.append(key.decode("utf-8").replace("batch:", "", 1))
#     return jsonify(batch), 200

# WIP: Trying to fetch data from a test table (in Datastore)
@batch.route("", methods=["GET"])
def get_batches():
    batch = []
    # for key in current_app.redis_client.scan_iter("batch:*"):
    #     batch.append(key.decode("utf-8").replace("batch:", "", 1))
    query = current_app.datastore_client.query(kind='uac')
    l = query.fetch()
    l = list(l)
    if not l:
        print("No result is returned")
    else:  
        d = dict(l[0])
        print(l)
    return jsonify(batch), 200


@batch.route("/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    for key in current_app.redis_client.sscan_iter(f"batch:{batch_name}"):
        batch.append(json.loads(current_app.redis_client.get(key.decode("utf-8"))))

    if len(batch) == 0:
        return api_error("Batch does not exist", 404)
    return jsonify(batch), 200
