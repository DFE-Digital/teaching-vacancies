# Integrations with other job posting services

We have 2 types of integrations:

## Integrations to import job adverts from external job posting services/ATs

These integrations allow organisations to get their vacancies automatically published in Teaching Vacancies through
ATS/job posting services.


### Legacy integrations

An original pilot took the approach of pulling each integration vacancies from ATS XML feeds and APIs.

Different integrations were built for the following ATS/job posting services:
- Broadbean
- Every
- Fusion
- My New Term
- Vacancy Poster
- Ventrus

The code for these integrations is defined within the [Vacancies::Import](/app/services/vacancies/import/) module.

The vacancies for these integrations are pulled hourly between 06:55 and 21:55 through the scheduled [Import From Vacancy Sources Job](/app/jobs/import_from_vacancy_sources_job.rb).

As more integrations were added, the difficulties to maintain and write the integrations providing custom parsing & mapping for each became more evident.

**This approach has been stopped and it planned to be removed**.

### New approach: Publisher ATS API

A new way to allow ATS to publish vacancies in Teaching Vacancies has been developed:

- [Publisher ATS API](publisher-ats-api)

## Integrations to export our internal vacancies to other job posting services

- [DWP Find a Job service](dwp-find-a-job.md)
