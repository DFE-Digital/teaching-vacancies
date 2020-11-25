# Continue to use Algolia as search engine

**Date: 2020-11-16**

## Status

**Decided**

## Parties Involved

 * Alex Bowen
 * Ben Mitchell
 * Cesidio Di Landa
 * Christian Sutter
 * Chris Taylor
 * Connor McQuillan
 * David Mears
 * Davide Dippolito
 * Joe Hull
 * Mili Malde

## Context

The current technical implementation of the Teaching Vacancies web application adopts Algolia as Search Engine to serve job search results to teachers. The development team migrated from Elastic Search to Algolia in April 2020. The reasons behind the migration are outlined in this document:

https://docs.google.com/document/d/1SjmXcnjJyAuAE8WRPrGX7MRrn6UQAfOQyb9GjGsa43c/edit?usp=sharing


A deeper analysis of TVS search requirements can be found in Search Analysis document:

https://docs.google.com/document/d/1fEQINBHTjI-TqcDfZ6IEDpNAghRGsnQg0EGJoD4E5wg/edit?usp=sharing

Teaching Vacancies conducted a review into which search engine option to take forward in April 2020 and Algolia was compared to Elastic Search. Despite limited technical justification, Algolia was selected as the preferred option to take forward, and the switch to Algolia standard plan was completed on the 18th of May 2020. Since that time a number of features closely linked to search have been introduced and improved.

## Options considered

### Option 1: Do nothing, stay with Algolia

The main reason to re-evaluate Algolia is that the SaaS solution doesn’t fully satisfy some of the expectations. From the technical perspective, testing is less empowering and can only be done at contract level as the integration with the search engine can only be stubbed.

Algolia has also not been adopted by any other teams within DfE which hinders knowledge sharing across services.


### Option 2: Migrate back to Elastic Search

ElasticSearch is an incredibly powerful tool that gives plenty of space to customisation and optimisation but comes with a cost: it is a search framework that needs a certain degree of expertise within the team to function correctly.

The possibilities to refine search capabilities with Elastic Search are endless, and it can fulfil all the current and future needs of Teaching Vacancies. Still, it requires a continuous effort to expand the team knowledge around its use.

### Option 3: Use PostgreSQL

Teaching Vacancies already utilizes PostgreSQL as main data store to support the application. Its relational nature facilitates all the application operations and could be used too to serve search results.

PostgreSQL is not a search engine and features like keyword search, fuzzy search and indexing would have to be implemented from scratch with significant engineering effort in terms of building and maintaining search functionalities.


## Decision

Based on a technical and financial review of the search engines assessed, the recommendation put forward is that Teaching Vacancies should continue to use the Algolia standard plan, and not revert back to using Elastic Search.

## Considerations and consequences

The technical review did not produce any compelling reasons to justify the opportunity cost and ongoing effort required to facilitate the adoption of Elastic Search. In addition, the financial cost of the Algolia standard plan is currently much less than Elastic Search, supporting this decision.
