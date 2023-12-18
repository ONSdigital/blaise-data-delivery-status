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
    print(f"EL'S DEBUG: batch_name: {batch_name}")

    batch = []
    filters = [('batch', '=', batch_name)]
    query = current_app.datastore_client.query(kind=DATASTORE_KIND, filters=filters)
    print(f"EL'S DEBUG: query: {query}")

    result = list(query.fetch())
    print(f"EL'S DEBUG: result: {result}")
    # I need result but without the <Entity('data-delivery-state', 'dd_LMS2309_GK1_13122023_155648.zip')
    # https://console.cloud.google.com/logs/query;cursorTimestamp=2023-12-18T16:26:23.479311Z;duration=PT1H;query=-resource.labels.instance_id%3D%229077296001786110456%22%0A-resource.labels.instance_id%3D%228181366072948613624%22%0A-resource.labels.instance_id%3D%223776308096453370360%22%0A-resource.labels.instance_id%3D%224352133296676200952%22%0Aseverity%3E%3DDEFAULT%0A-resource.labels.instance_id%3D%22622545174696791813%22%0A-resource.labels.function_name%3D%22nisra-case-mover-trigger%22%0A-protoPayload.authenticationInfo.principalEmail%3D%22elinor.thorne@ons.gov.uk%22%0A-%22%2Fbts%2F%22%0A-%22https:%2F%2Fdev-kt02-cati%22%0A-%22https:%2F%2Fdev-kt02-ernie%22%0A-%22https:%2F%2Fdev-kt02-cawi%22%0A-%22https:%2F%2Fdev-kt02-uac%22%0A-%22https:%2F%2Fdev-kt02-tobi%22%0A-%22https:%2F%2Fdev-kt02-dqs%22%0A-%22https:%2F%2Fdev-kt02-bam%22%0A-%22https:%2F%2Fdev-kt02-dashboard%22%0A-%22Successfully%20created%20profile%20HEAP.%22%0A-%22Successfully%20collected%20profile%20HEAP.%22%0A-%22Successfully%20uploaded%20profile%20HEAP.%22%0A-%22Successfully%20collected%20profile%20WALL.%22%0A-%22Successfully%20uploaded%20profile%20WALL.%22%0A-%22Successfully%20collected%20profile%20WALL.%22%0A-%22Successfully%20uploaded%20profile%20WALL.%22%0A-%22entered%20the%20stopped%20state.%22%0A-%22entered%20the%20running%20state.%22%0A-%22disposition%22%0A-%22%5Broot%5D%20@%22%0A-%22Reason:%20RulesEngine.%22%0A-%22root%5Broot%5D%20@%20%20%5B127.0.0.1%5D106534%203574856367%20Query%22%0A-%22Attempting%20to%20create%20profile.%22%0A-%22Successfully%20created%20profile%20WALL.%22%0A-%22-%20latest%20version%20installed%22%0A-%22Fetching%22%0A-%22__google_connectivity_prober@localhost%20on%20fakedatabase%20using%20Socket%22%0A-%22pid%22%0A%22EL'S%20DEBUG:%22%0Atimestamp%3D%222023-12-18T16:26:23.479311Z%22%0AinsertId%3D%22658072af0007504ff8d8078c%22?project=ons-blaise-v2-dev-kt02

    print(f"EL'S DEBUG: len(result): {len(result)}")
    if len(result) == 0:
        return api_error("Batch does not exist", 404)

    for entity in result:
        print(f"EL'S DEBUG: entity: {entity}")
        batch.append(entity)

    print(f"EL'S DEBUG: batch: {batch}")
    print(f"EL'S DEBUG: jsonify(batch): {jsonify(batch)}")
    return jsonify(batch), 200
