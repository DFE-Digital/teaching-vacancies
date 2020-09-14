# TEVA-1249 Spike - can we get Papertrail data into BigQuery

## Description

It would be useful to be able to analyse/query logging data in BigQuery. For example this would mean that we can:

Work out the number of site searches performed by users so that we can compare this to the number of site searches tracked in Google Analytics, and use this to calculate a scale factor that compensates for tracking data lost due to cookie opt out.

Analyse the site searches, vacancy views etc. carried out by users with a full sample size (not just the limited sample we’ll get in GA post-cookie opt out)

A solution would need to look something like all logging data from production in Papertrail being stored in structured form in BigQuery. This could be a realtime integration, or could be a nightly scheduled data transfer.

Ideas so far:

- Ship the logfiles to S3 and set up a transfer into BigQuery from there: https://cloud.google.com/bigquery-transfer/docs/s3-transfer-intro?hl=en_GB
- A third party integrator
- Log ship the relevant logfiles into Google Cloud Storage, from where BigQuery can pick up the data

## Acceptance criteria:

- We have identified a range of options to achieve this.
- We have agreed which - if any - of these options to take forward.
- We have created ticket(s) for this.

### Papertrail formats

From [permanent log archives](https://documentation.solarwinds.com/en/Success_Center/papertrail/Content/kb/how-it-works/permanent-log-archives.htm) we read

> Archives are in tab-separated values (.tsv) format, so a line actually looks like this:
```
50342052\t2011-02-10 00:19:36 -0800\t2011-02-10 00:19:36 -0800\t42424\tmysystem\t208.122.34.202\tUser\tInfo\ttestprogram\tLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
```
> The TSV files are gzip-compressed (.gz) to reduce size. Gzip compression is compatible with UNIX-based zip tools and third-party Windows zip tools such as 7-zip and WinZip.

### Papertrail export to S3

Papertrail has documentation for [Automatic S3 archive export](https://documentation.solarwinds.com/en/Success_Center/papertrail/Content/kb/how-it-works/automatic-s3-archive-export.htm?cshid=pt-how-it-works-automatic-s3-archive-export) which is in three steps:
- sign up for AWS
- create a bucket for log archives
- share write-only access to Papertrail for nightly uploads

### Import from S3 to BigQuery - formats

We'll first address how we could get data into BigQuery from AWS S3.
From BigQuery's [Overview of Amazon S3 transfers](https://cloud.google.com/bigquery-transfer/docs/s3-transfer-intro?hl=en_GB) we see two likely formats:
- Comma-separated values (CSV)
- JSON (newline-delimited)

And that with these two formats, it's [faster to load them when uncompressed](https://cloud.google.com/bigquery/docs/loading-data#loading_compressed_and_uncompressed_data):

> For other data formats such as CSV and JSON, BigQuery can load uncompressed files significantly faster than compressed files because uncompressed files can be read in parallel. Because uncompressed files are larger, using them can lead to bandwidth limitations and higher Cloud Storage costs for data staged in Cloud Storage prior to being loaded into BigQuery. Keep in mind that line ordering isn't guaranteed for compressed or uncompressed files. It's important to weigh these tradeoffs depending on your use case.
> 
> In general, if bandwidth is limited, compress your CSV and JSON files by using gzip before uploading them to Cloud Storage. Currently, when you load data into BigQuery, gzip is the only supported file compression type for CSV and JSON files. If loading speed is important to your app and you have a lot of bandwidth to load your data, leave your files uncompressed.

From [Loading data from cloud storage - CSV](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv)

#### Dates and timestamps

> When you load CSV or JSON data, values in DATE columns must use the dash (-) separator and the date must be in the following format: YYYY-MM-DD (year-month-day).
> When you load JSON or CSV data, values in TIMESTAMP columns must use a dash (-) separator for the date portion of the timestamp, and the date must be in the following format: YYYY-MM-DD (year-month-day). The hh:mm:ss (hour-minute-second) portion of the timestamp must use a colon (:) separator.

#### Support for tab-separated values

Using the `bq` CLI, we would need to specify the separator for fields in a CSV file, passing with the `--field_delimiter` flag. We read:
> BigQuery also supports the escape sequence "\t" to specify a tab separator. The default value is a comma (`,`).

### Costs

- BigQuery import from S3 - none (see [Pricing](https://cloud.google.com/bigquery-transfer/pricing))
- Papertrail export to S3
- S3 additional storage costs. [Papertrail suggest](https://documentation.solarwinds.com/en/Success_Center/papertrail/Content/kb/how-it-works/automatic-s3-archive-export.htm?cshid=pt-how-it-works-automatic-s3-archive-export):
> Archived log files compress extremely well, often 15:1 or more, so the total cost of archived logs stored in S3 is extremely small (often pennies per month). Storing a long-term log archive in your S3 bucket will almost always cost less than 1% of the total cost of Papertrail.

### CloudFront

- TVS uses Amazon's Cloudfront as a Content Delivery Network. It is possible to store CloudFront logs in S3 (including `querystring`), and [query with Athena](https://docs.aws.amazon.com/athena/latest/ug/cloudfront-logs.html) or presumably, into BigQuery using the S3 to BigQuery option detailed above.

Standard logging is free to enable
Looking at Terraform, would be enabled as per [logging-config-arguments](
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#logging-config-arguments)
```
  logging_config {
    include_cookies = false
    bucket          = "mylogs.s3.amazonaws.com"
    prefix          = "myprefix"
  }
```


### Alternatives


- Log additional required metrics into the database while the website is being used
- Export the existing AuditData table into BigQuery for further analysis.
- Within teacher services, we are migrating from Papertrail to [Logit.io](https://logit.io/), so if we did need to analyse what's being stored in the logs, we would incur less technical debt by avoiding a dependency on Papertrail.
