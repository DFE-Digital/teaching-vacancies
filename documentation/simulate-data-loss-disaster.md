# Simulate Data Loss Disaster

To simulate disaster recovery, do the following:

- Notify Devs of simulation
- Create test data to verify after recovery
- Wipe out data:
    - Login to PaaS using conduit: `cf login --sso`
    - Connect to PostgreDB instance: `cf conduit teaching-vacancies-postgres-dev -- psql`
    - Get database `owner`: run `\dt` once connected to database. The owner is described in the fourth column of the schema
    - Run command to drop table - `drop owned by rdsbroker_xxxxx_xxxx_xxxx_xxxxx_xxxxx_manager;`

- Follow the [disaster recovery documentation](disaster-recovery.md) to recover data.


# Simulate Loss of Database Instance Disaster

To simulate loss of database instace disaster, do the following:

- choose an environment to simulate disaster on e.g. dev or qa
- Notify Devs of simulation
- identify any service_key associated with the database e.g. `cf service-keys teaching-vacancies-postgres-review-pr-4582`
- Delete service_key e.g `cf delete-service-key -f teaching-vacancies-postgres-review-pr-4582 postgres_instance_service_key-review-pr-4582`
- Delete database instance e.g. `cf delete-service teaching-vacancies-postgres-review-pr-4582 -f`
- Follow the [disaster recovery documentation](disaster-recovery.md) to recover lost instance.
