# Notes on Google Drive API usgae

## Background

We use Google Drive via its API to manage uploads for the Teaching Vacancies Service. This document serves as a central
location in close proximity to our codebase to consolidate notes and learning. 

## AV 

One reason we chose Google Drive was to avoid having to build and maintain a document-store level antivirus solution.
Experience teaches that these are difficult to integrate and maintain. Google Drive provides this as a standard part of
their service.

### How Google Drive normally works with AV

If you manually upload an infected file to Google Drive, it **will not** alert you at upload time. It waits until
someone attempts to download the file before scanning and shows the downloader a modal explaining that the file is
infected and offering to allow them to continue if they accept the risk. 

### A note on using eicar in testing 

When testing the API, or manual Google Drive interactions for that matter, it **does not** detect [the eicar test
malware](https://www.eicar.org/?page_id=3950) if it is embedded in a `.docx` file. This is a peculiarity of `.docx`
format and the way eicar works and is not indicative of a failure on the part of Google Dive. [Details
here](https://community.mcafee.com/t5/Endpoint-Security-ENS/EICAR-file-detected-in-txt-but-not-in-doc-docx/m-p/606933).
In order to ensure your testing does not generate false negatives, please use the
[eicar.com](https://secure.eicar.org/eicar.com) or [eicar_com.zip](https://secure.eicar.org/eicar_com.zip) files.

### Testing eicar.com uploads

I used the `google_drive` gem, which is a simplified wrapper around the full Google API gem. I was able to upload
`eicar.com`, but I was not able to download it again (`Google::Apis::ClientError: Invalid request`). However, google
drive treated it as if I had uploaded raw malware - when I attempted to download if using chrome, I got a message saying
it violated their terms of service. I could not make google drive recognise eicar in a `.zip` file no matter how I
uploaded or downloaded it.  I **think** this is a limitation of eicar, but need to do some additional research before I
can say for certain. 
