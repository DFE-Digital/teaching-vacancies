# Integration with DWP "Find a job" service

We publish our published internal vacancies to the Department of Work and Pensions [Find a job service](https://findajob.dwp.gov.uk/).

## Overview of the integration
Find a job service integration is done through daily XML bulk uploads to their SFTP server.

There are 2 bulk upload types:

1. Uploading new/edited vacancies (published/updated on TV vacancies)
2. Uploading expired/deleted vacancies (manually closed early on TV vacancies)

```mermaid
block-beta
columns 3
block:TeachingVacancies:3
    columns 3
    TeachingVacanciesTag>"Teaching Vacancies"] space:2
    space Database[("Database")] space

    PublishedAndUpdated["PublishedAndUpdated"]
    space
    ClosedEarly["ClosedEarly"]

    Database --> PublishedAndUpdated
    Database --> ClosedEarly

    XmlPublish[\"XML: to publish/update"/]
    space
    XmlDelete[\"XML: to delete"/]

    PublishedAndUpdated-- "Generates" -->XmlPublish
    ClosedEarly-- "Generates" -->XmlDelete
end
style TeachingVacancies fill:#e6f2ff,stroke:#333,stroke-width:2px

block:FindAJob:3
    columns 3
    FindAJobTag>"Find a job"] space:2
    space
    block:SFTP
        columns 3
        SFTPTag>"SFTP"] space:2
        Inbound Outbound
    end
    style SFTP fill:#ffcccc,stroke:#333,stroke-width:2px
    space
    space space ImportOutput[\"Import output reports"/]
    space ProcessInput(["Daily Process Inboud contents"]) space
    space Website(("Find a Job website"))
end
style FindAJob fill:#ffffcc,stroke:#333,stroke-width:2px

XmlPublish--"SFTP Upload" -->Inbound
XmlDelete--"SFTP Upload" -->Inbound


Inbound --> ProcessInput
ProcessInput --> Website
ProcessInput-- "Generates" -->ImportOutput
ImportOutput --> Outbound

classDef tag fill:#99ccff,stroke:#333;
classDef output fill:#d9ffb3,stroke:#333;
classDef datasource fill:#ffcc99,stroke:#333;

class TeachingVacanciesTag,FindAJobTag,SFTPTag tag
class XmlPublish,XmlDelete,ImportOutput,Website output
class Database,Inbound,Outbound datasource

```

## Process overview
The process has 3 stages:
1. Query to filter the vacancies that need to be published/updated or deleted in Find a Job.
2. Generate a bulk XML temporal file from those vacancies following Find a Job file specs.
3. Push the file to the Find a Job service SFTP server.

```mermaid
---
title: DWP Find a Job integration code structure
---
classDiagram
  PublishedAndUpdated *-- Upload : composition
  ClosedEarly *-- Upload : composition
  NewQuery *-- Versioning : inclusion
  NewXml *-- ParsedVacancy : composition
  ParsedVacancy *-- Versioning : inclusion
  ExpiredXml *-- Versioning : inclusion
  PublishedAndUpdated *-- NewXml : composition
  PublishedAndUpdated *-- NewQuery : composition
  ClosedEarly *-- ExpiredXml : composition
  ClosedEarly *-- ExpiredQuery : composition

  class PublishedAndUpdated {
    from_date
    +call()
    -filename()
  }

  class ClosedEarly {
    from_date
    +call()
    -filename()
  }

  class Upload {
    xml
    filename
    +call()
    -upload_to_find_a_job_sftp(file_path)
  }

  class Versioning {
    DAYS_BETWEEN_REPOSTS
    MIN_LIVE_DAYS
    MAX_LIVE_DAYS
    +versioned_reference(vacancy)
    +version(vacancy )
  }

  namespace PublishedAndUpdatedVacancies {
    class NewXml["Xml"] {
      vacancies
      +xml()
      -vacancy_to_xml(vacancy,xml)
    }

    class NewQuery["Query"] {
      from_date
      +vacancies()
      -vacancies_published_after_date()
      -vacancies_published_before_date()
      -vacancies_updated_after_date()
      -vacancies_to_repost_today()
    }

    class ParsedVacancy {
      vacancy
      +reference()
      +job_title()
      +organisation()
      +apply_url()
      +category_id()
      +description()
      +expiry()
      +status_id()
      +type_id()
      -date_from_publishing_version(offset_days)
      -description_paragraph(title, text)
      -html_to_plain_text(html)
      -sanitize(text)
    }

  }

  namespace ClosedEarlyVacancies {
    class ExpiredXml["Xml"] {
      vacancies
      +xml()
    }

    class ExpiredQuery["Query"] {
      from_date
      +vacancies()
    }
  }
```

## Uploading published/updated vacancies

The service orcherstating the upload of new/edited vacancies is [Vacancies::Export::DwpFindAJob::PublishedAndUpdated](../../app/services/vacancies/export/dwp_find_a_job/published_and_updated.rb)

### What vacancies are exported?
We publish vacancies that fall on any of these conditions:
- Got published on/after the given date.
  EG: Providing yesterday's date, all the vacancies published yesterday and today will be returned.
- Were previously published but got updated after the given date.
  In this case, the publish will update the vacancy changed info in the Find a Job service.
- Were previously published but need to be reposted on Find a Job service.

```mermaid
block-beta
columns 8
block:TeachingVacancies:8
    columns 3
    space Database[("Database\nVacancies")] space

     RecentlyPublished{"Recently\npublished"}
     RecentlyUpdated{"Recently\nupdated"}
     NeedToBeReposted{"Need to be\nreposted"}

    space Query space

    Database --> RecentlyPublished
    Database --> RecentlyUpdated
    Database --> NeedToBeReposted
    RecentlyPublished --> Query
    RecentlyUpdated --> Query
    NeedToBeReposted --> Query
end
style TeachingVacancies fill:#e6f2ff,stroke:#333,stroke-width:2px

classDef querybit fill:#ffffcc,stroke:#333;
classDef datasource fill:#ffcc99,stroke:#333;
class RecentlyPublished,RecentlyUpdated,NeedToBeReposted querybit
class Database datasource
```
### Reposting Vacancies.
Find a Job service has a limit on the vacancy closing/expiry date:

**A vacancy advert must expire after a maximum of 30 days from the date it got published.**

For a new vacancy to be accepted we must either:
- Do not specify an expiry date: It will default to 30 days after the publish date.
- Specify an expiry date between 1 and 30 days after the publishing date.

For a vacancy edit/update to be acceoted we must either:
- Do not specify an expiry date: It will keep the original value.
- Set a specific expiry date: Between 1 and 30 days after the original publishing date.

#### The problem with this limitation
The majority of our live vacancies have closing dates way beyond a month from the publish date.

```mermaid
timeline
    title Max life of an advert in Find a Job
    Day 1 : Advert gets Published
    Day 31 : Advert expires.
           : Last day published
    Day 32 : Advert no longer published

```

#### How do we ensure the vacancy from TV is live in the DWP Find a Job service after 30 days from being published?

We will republish the vacancy as a new advert on DWP Find a Job every 31 days.

**EG: Lifetime of a TV vacancy published today, that expires in TV 70 days later:**
```mermaid
timeline
    title Vacancy: TV to Find a Job cycle
    Day 1 : TV exports the vacancy for first time
          : Advert reference is the vacancy "id"
          : Advert expiry date is left to default 30 days after today
          : Advert "id" gets Published
    Day 31 : Advert "id" Expires
    Day 32 : Advert "id" no longer published
           : TV exports the vacancy for second time
           : New advert with reference "id-1"
           : Advert expiry date is left to default 30 days after today
           : Advert "id-1" gets published
    Day 62 : Advert "id-1" expires
    Day 63 : Advert "id-1" no longer published
           : TV exports the vacancy for third time
           : New advert with reference "id-2"
           : Advert expiry date is set to 8 days after today, matching TV expiry date.
           : Advert  "id-2" gets published
    Day 71 : Advert "id-2" Expires same day as in TV
    Day 72 : Advert "id-2" no longer published

```

## Uploading vacancies closed early

The service orcherstating the upload of vacancies closed early is [Vacancies::Export::DwpFindAJob::ClosedEarly](../../app/services/vacancies/export/dwp_find_a_job/closed_early.rb)

### What vacancies are exported?

Vacancies that got manually closed by their publisher in Teaching Vacancies prior to the original closing date.

For those vacancies, we will need to send an update to DWP Find a Job service so they get removed from their service on the next import.

We identify them by querying vacancies under all the following conditions:
- Are expired.
- They expired on/after the given date.
- Their update timestamp is within (before or after) 60 seconds form their closing datetime.

This criteria relies on, when the vacancies are manually closed, they get their closing datetime set to "right now", what also gets registered in the `updated_at` DB timestamp.
There will be some difference on the exact timestamps, so we were generous and set 60 secs to be sure no closed vacancy stays posted in the Find a Job service.

## How do we schedule the uploads
The bulk upload file/s are imported once per day by Find a job service.

Teaching Vacancies has no control on the frequency or timing of these imports, besides pushing info daily to be imported by Find a job.

Every night we will push:
- the vacancies that got published or updated over the last 25 hours.
- the vacancies that got manually closed/expired by the publisher over the last 25 hours.

Note: We use 25 hours to have 1h overlap between runs. Better to have some vacancies updated/deleted twice than missing from being exported
due to its update in TV happening at the same time as the scheduled export run.

## How to test-debug changes
Find a Job service does not offer a testing environment, so all the testing needs to be done over production environment.

The process for end-to-end manually testing goes through:
1. Connect to a TV production console.
2. Manually push the export to Find a Job service.
  - Eg: `Vacancies::Export::DwpFindAJob::PublishedAndUpdated.new(1.hour.ago).call`
3. Using a FTP Client, connect to the DWP Find a Job SFTP Server.
  - The connection details are defined in the env variables:
    - `FIND_A_JOB_FTP_HOST`
    - `FIND_A_JOB_FTP_PORT`
    - `FIND_A_JOB_FTP_USER`
    - `FIND_A_JOB_FTP_PASSWORD`
4. On the FTP server, you will find:
  - The files to be imported placed in the `Inbound` folder.
  - The output of the recent upload/expiry exports placed in the `Outbund` folder.
  - Already imported files placed in the `processed` folder.
5. You can download/delete the files, editing them locally and re-upload them.
6. Eventually, the files at the `Inbound` folder will be imported, moved to `processed` and a report generated at `Outbound`.
5. You can see/manage the job adverts through the [Find a Job employer dashboard](https://findajob.dwp.gov.uk/employer/sign-in)
  - An administrator has to invite you to Teaching Vacancies team. Our PM is the current admin.
  - You will be able to manually Delete the adverts there.


## Technical specification

The specification documentation for DWP Find a job service can be found [here](https://static.findajob.dwp.gov.uk/images/find_a_job_bulk_upload_spec_v3.0.pdf)


