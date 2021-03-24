service: data-delivery-status
runtime: python37

env_variables:
  REDIS_HOST: _REDIS_HOST
  REDIS_PORT: _REDIS_PORT

vpc_access_connector:
  name: projects/_PROJECT_ID/locations/europe-west2/connectors/vpcconnect

basic_scaling:
  idle_timeout: 60s
  max_instances: 1

handlers:
- url: /.*
  script: auto
  secure: always
  redirect_http_response_code: 301