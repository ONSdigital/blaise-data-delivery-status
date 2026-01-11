service: dds
runtime: python313

vpc_access_connector:
  name: _VPC_CONNECTOR

basic_scaling:
  idle_timeout: 60s
  max_instances: 1

handlers:
- url: /.*
  script: auto
  secure: always
  redirect_http_response_code: 301
