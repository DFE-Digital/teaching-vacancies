## Introduction

To help hiring staff understand how much traffic their vacancies receive, and where that traffic comes from, we track and store view data in the vacancy_analytics table. This allows us to surface basic analytics in the publisher interface, without introducing performance overhead or relying on external analytics platforms.

## Our approach

When a user views a vacancy:

1. `VacanciesController#show` calls `VacancyAnalyticsService.track_visit`, which normalises the referrer (for example `google`, `direct`, `internal`, or `jobalert` for email links).
2. The service upserts directly into the vacancy_analytics table, incrementing that referrer's count in the vacancy's single row with one atomic SQL statement.

There is no Redis buffer, background job or aggregation step, so the data is available immediately. The upsert is one small write per view, on a table with one row per vacancy.

## The vacancy_analytics table

Each row in the vacancy_analytics table represents a single vacancy. View counts are stored in the referrer_counts column (a JSONB field), which maps referrer domains (e.g. google.com, twitter.com, etc.) to the number of views.

We chose this approach to avoid creating one row per referrer per vacancy as this could lead to the table getting very large as the service scales and (hopefully!) the number of vacancies we publish, and sources of traffic, continues to increase.

It is worth noting that we do not store the dates of the views. This was deemed to be outside the scope of this feature as we do not believe hiring staff are likely to use this data for complex analysis. The larger MATs that are more likely to carry out more complicated analysis typically have their own systems for tracking things like seasonal trends.

## Moving forward

If requirements evolve (e.g. if hiring staff want to view trends over time), we could adopt an approach similar to what the Apply team uses:

- Track analytics in BigQuery via dfe-analytics (which we already do).
- Work with performance analysts to design a table/view in BigQuery optimized for this use case.
- Periodically query this table/view and import summarized metrics to Postgres.

This would allow us to deliver more granular insights to users without impacting application performance.
