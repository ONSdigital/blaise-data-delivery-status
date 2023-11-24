import os

from app.app import app, init_redis, init_datastore

# TODO: Remove when Datastore client is set up
# init_redis(app)
init_datastore(app)

if __name__ == "__main__":
    port = os.getenv("PORT", "5008")
    app.run(host="0.0.0.0", port=port)
