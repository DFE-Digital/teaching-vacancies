# Data: Seeds and external

If you use the devcontainer, the database will be created and seeded on first run using standard
`rails db:prepare`. The seeds generate a number of fake vacancies, job applications, and users,
as well as importing required data from a number of external services.

You shouldn't have to refresh the external data, but if you do need to, you can with the following tasks:

```bash
# Import all schools, trusts, and local authorities from DfE's Get Information About Schools
bundle exec rails gias:import_schools

# Import location polygon data from the Office for National Statistics
bundle exec rails ons:import_all
```

If ever you want to start over, you can delete and re-seed using:

```bash
bundle exec rails db:drop db:prepare
```

The _SQLTools_ VS Code extension is installed and configured in the devcontainer by default and can
be used to browse the database and run SQL queries. The `psql` tool is also installed, so you can
use `rails dbconsole` or even just `psql tvs_development`.

