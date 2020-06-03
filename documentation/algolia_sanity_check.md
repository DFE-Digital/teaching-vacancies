# To check whether a change to the index breaks the indexing

This is a quick how-to on how to get quick feedback when writing changes to the Algolia indexing. It's not a substitute for tests.

Sanity-check whether a change to the index breaks the indexing by using the below configuration in your development environment, and either running `Vacancy.reindex` in the rails console or populating your database.

```ruby
algoliasearch per_environment: true, disable_indexing: Rails.env.production? do
```

This creates a separate index called Vacancy_{environment}, and will only
be run in non-production environments.

Double-check that you aren't about to put data in the real database with:

```ruby
Vacancy.index.name # should be e.g. Vacancy_staging
```

You will also need to comment out or adapt the add_replica blocks.
