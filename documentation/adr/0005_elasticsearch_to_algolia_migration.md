# Switch from ElasticSearch to Algolia for search functionality

**Date: 08/04/2020**

## Status

**Discussing**

Sumarises to output and decisions taken as a result of spikes:

- [TEVA-615](https://docs.google.com/document/d/14hf17sSuQu7N0cBa6tvdC_WwiHHBVJ5aA7xDPQghTT0/edit?usp=sharing)
- [TEVA-616](https://docs.google.com/document/d/1Z23ethqb3cICGvx61Nbr0yEbsTAoULiKSXSmGpW1unA/edit?usp=sharing)

## Context

ElasticSearch (ES) is used as the search engine for:

- UI search for vacancies
- Querying vacancies to construct email job alerts based on a users criteria.

They both currently use a ruby ES client library to submit queries. Both use a base client class(es) that search and job alerts functionality extend from.

Current search has been identified as not giving optimal search results and job alerts are based on very simplistic search rules currently. Is there a better tool to use that is more easily configurable?

Currently indexing and maintaining ranking of search terms is an engineering task.

## Decision

Algolia was identified an alternative as it:

- has easier/improved 'out of the box' functionality yielding better search results
- is up to 200x faster than ES
- has a comprehensive dashboard UI that means rankings/weightings could potentially be managed by wider range of people
- has a comprehensive toolset including UI components and libraries

## Consequences

The data needs to be indexed in Algolia. They have a ruby tool for doing this [here](https://github.com/algolia/algoliasearch-rails)

UI search will be re-implemented using `instantSearch`, the algolia browser javascript client, and the markup and CSS refactored to use algolia class/id hooks.

Job alert search will implement the ruby algolia client and the query refactored accordingly. This shouldnt require substantial change to existing code. Code for the UI search can be removed.
