# Replace Google Sheets with Big Query as a reporting database
Date: 20/01/2020

## Status
approved

## Context
We need to replace google sheets as a reporting database due to us approaching the spreadsheet limit.

## Decision
To use Google Big Query instead of Google Sheets and export our data into Big Query tables.

# Consequences
For the volume of data we currently have at the time of writing, we can take advantage of Big Query's pricing model (Pay for above 1TB query usage / 10GB storage, our DB currently holds ~ 2 GB of data). However, the volume of the data stored in Big Query could increase over time and we would therefore fall within the boundaries of the pricing model.
