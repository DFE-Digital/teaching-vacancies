# Migrate from Algolia to Postgres-based search

**Date: 2021-09-22**

## Status

**Decided**

## Context and Problem Statement

Given the user needs we want to meet with our search functionality, and the cost and complexity involved in our integration with Algolia, would we be better off with a simpler solution of leveraging our existing database for search?

## Decision Drivers

* Financial cost of Algolia (and risk of eventually losing our cheap grandfathered legacy plan)
* Technical complexity and brittleness of Algolia integration
* Lack of customisability and lack of configuration-as-code on Algolia
* Simplicity of underlying search requirements means enterprise-grade search engine is overkill
* Lack of ability to integration test search results when using SaaS search engine
* Availability of constantly improving full-text search functionality in our database (PostgreSQL)
* Potential for richer geographical querying using PostGIS

## Considered Options

* Stay on Algolia
* Move to using PostgreSQL for search

## Decision Outcome

Decided to migrate away from Algolia and move to using our database for search functionality.

### Positive Consequences

* Simplified infrastructure and one fewer third-party service integration
* Significant complexity savings in search code
* Ability to integration test search results and keep search configuration in code (versioned and auditable)
* End of reliance on Algolia's goodwill in keeping us grandfathered on their legacy plan
* Minor cost savings in the short term (and we no longer need to avoid potential increases in queries in the long term)
* Improved performance and reliability due to not having to interact with a third-party service
* Ability to completely control and debug all aspects of how search works
* Richer geographical querying through use of PostGIS

### Negative Consequences

* Some implementation effort (estimated at 2x developers for ~3-4 sprints)
* Synonym logic will need custom implementation (but at the same time, this allows us to make it significantly "smarter" than on Algolia)
* Typo tolerance/fuzzy search will need custom implementation (but this is an edge-case for us because the majority of queries are straightforward)
