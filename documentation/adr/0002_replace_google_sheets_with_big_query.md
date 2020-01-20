# Replace Google Sheets with Big Query as a reporting database

Date: 20/01/2020

## Prologue (Summary)

As a result of TVS' Production Data Spreadsheets approaching the [5 million cell limit](https://support.google.com/drive/answer/37603?hl=en). We decided to replace Google Sheets with Google Big Query as TVS' reporting database. With our current volume of data, we would be operating within the free tier of the pricing model; however we accept that we could fall outside the boundaries of this free tier in future.

### Status: **Approved**

## Discussion (Context)

In our codebase, we were using the Google Sheets API to write data to Google Sheets - effectively using Google Sheets as a reporting database.

Advantage:

- It was free.

Disadvantages:

- Google Sheets has a cell limit per spreadsheet. We had reached the limit on a couple of these spreadsheets, which meant that newer data could not be added without deleting older data. We estimated that the spreadsheet containing data on vacancies would run out of space in Q1 2020.
- Accidental edits to spreadsheets were common, and these resulted in substantial maintenance effort to rectify them.
- Google Sheets formulae were more difficult to maintain and hand over than SQL queries.

We looked at several options to replace Google Sheets and assessed them based on:

- Amount of development work required to set them up.
- Ability to retain large volumes of anonymised historical data
- Storage of all data (historic and recent)
- Ability to remove personal data from reporting datasets
- Ease of integrating with existing tools
- Cost for usage

The options we looked at were:

- Creating a read replica of the production DB
- Data streaming from the API directly into the dashboard
- Creating a new DB solely for reporting
- Using a data warehouse, e.g. Google Big Query, AWS RedShift

The table below summarises the results of investigating the options:

|  Option                                                                                     |  Do nothing \(keep the Google Sheet\)            |  Read replica of the production database |  API\-to\-dashboard ‘data streaming’ |  PostgreSQL reporting database      |  Big Query data warehouse                     |  Amazon Redshift data warehouse                                               |
|---------------------------------------------------------------------------------------------|--------------------------------------------------|------------------------------------------|--------------------------------------|-------------------------------------|-----------------------------------------------|-------------------------------------------------------------------------------|
|  One\-off development required?                                                             | No                                               | Yes                                      | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |
|  Further development & reporting configuration required when new data needed for reporting? | Yes                                              | No                                       | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |
|  Further work required if we needed to migrate from AWS to Azure?                           | No                                               | Yes                                      | No                                   | Yes                                 | No                                            | Yes                                                                           |
|  Could store all data currently needed?                                                     | No                                               | Yes                                      | No                                   | Yes                                 | Yes                                           | Yes                                                                           |
|  Able to retain large volumes of anonymised historical data without extra development work  | No                                               | No                                       | No                                   | No                                  | Yes                                           |  No?                                                                          |
|  Would allow personal data to be removed from the reporting dataset                         | Yes                                              | No                                       | Yes                                  | Yes                                 | Yes                                           | Yes                                                                           |
|  Could connect to Data Studio                                                               | Yes                                              | Yes                                      | No                                   | Yes                                 | Yes                                           | Yes                                                                           |
|  Could connect to Power BI cloud                                                            | No                                               | No                                       | Yes                                  | No                                  | No                                            | No                                                                            |
|  Could connect to Tableau                                                                   | Yes                                              | Yes                                      | Yes                                  | Yes                                 | Yes                                           |  Yes                                                                          |
|  Cost / commercial model                                                                    |  Included in G Suite licence \(priced per user\) |  Extension of existing AWS contract      | ?                                    |  Extension of existing AWS contract |  Pay for above 1TB query usage / 10GB storage |  Pay for cluster per hour \($0\.32 per hour, or less on a reserved instance\) |
| Cost                                                                                        | None                                             |  ~£600 pa                                      | ?                                    | ~£600 pa                                   |  Assume free\!                                |  ~£2300 pa                                                                    |

## Solution

Use Google Big Query instead of Google Sheets and export our data into Big Query tables.

- TVS had a GCP account which meant that we could set up a Big Query project quickly.
- GCP allows us to manage access rights and set permissions for Big Query related jobs.
- From discussing with users of Big Query, there are no idle costs (i.e only pay when querying and for storage) as opposed to AWS Redshift.
- We can still maintain control of what data is sent to Big Query.
- Our volume of data (~ 2 GB as of the time of writing) means that we’re using it for free for now.
- We use Google Data Studio, which can easily integrate with it.
- Big Query also gives a range of BI tools to help with reporting and managing historic data.

Ultimately, the objective was to eliminate the need for using google sheets. Big Query provides an attractive solution that removes the dependency of using the Google Sheets as a reporting database, provides security in terms of visibility and access to data and can integrate with other Google products, (including google sheets to study or work on the data, if necessary).

Notes taken while investigating a replacement for the TVS Spreadsheets are [here](https://docs.google.com/document/d/1HlN4vY8Uv1alnqwOYjmaoyQ3GCKyd4sI7_E42zp7fMo/edit?usp=sharing).

## Consequences

For the volume of data we currently have at the time of writing, we can take advantage of Big Query's pricing model as our DB currently holds ~2 GB of data (You pay for above 1TB query usage / 10GB storage). However, the volume of the data stored in Big Query could increase over time and could, therefore, fall outside the boundaries of the free tier of the pricing model in future.
