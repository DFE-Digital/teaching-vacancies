# Data: Seeds and external

The database is created and seeded using standard `rails db:prepare`, which the devcontainer runs
on first start and which you run yourself in the native setup. The seeds generate a number of fake
vacancies, job applications, and users, as well as importing required data from a number of
external services.

The seeds also create a "Testing ATS Client" ATS API client with 30 live, model-validated external
vacancies for the [Publisher ATS API](../../service/integrations/publisher-ats-api.md). Most live
vacancies arrive this way, so review apps include them so that QA covers external vacancies too.
They close between 1 and 30 weeks after seeding, mostly before the other seeded vacancies, so they
fill the first page of the default (closing date) search results.

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
