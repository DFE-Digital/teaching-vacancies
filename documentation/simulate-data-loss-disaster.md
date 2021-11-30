# Simulate Data loss Disaster

To simulate disaster recovery, do the following:

- Notify Devs of simulation
- Create test data to verify after recovery
- Wipe out data:
    - Login to PaaS using conduit: `cf login --sso`
    - Connect to PostgreDB instance: `cf conduit teaching-vacancies-postgres-dev -- psql`
    - Get database `owner`: run `\dt` once connected to database. The owner is described in the fourth column of the schema
    - Run command to drop table - `drop owned by rdsbroker_xxxxx_xxxx_xxxx_xxxxx_xxxxx_manager;`

- Follow the [disaster recovery documentation](disaster-recovery.md) to recover data.
