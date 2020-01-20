# Notes on Google Drive API Usage 

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

I have just manually tried the `POC_phpinfo-metadata.jpg` from
[here](https://github.com/fuzzdb-project/fuzzdb/tree/master/attack/file-upload/malicious-images) and Drive seems to
reliably detect it. It allowed me to create a shared URL, but then showed me the ToS violation message when I tried to
use the link in incognito mode. When I tried to download the file from Drive, directly, it gave me a virus warning. I
believe this file will work for progressing my testing with the drive API.

### The quick and simple way to check for viruses

We can use the existing `google_drive` gem to manage the uploads and set the ACLs:

  1. Ensure the Google Drive API is enabled in the GCP dashboard:
     `https://console.cloud.google.com/apis/dashboard?project=drivevirustesting`
  1. Create a service account to access Google Drive for these uploads
  1. Generate a service account key for each environment you want to use the uploader in (dev, staging, prod and so on)
  1. Associate the key with your environment according to your existing protocol for doing so. 
  1. Upload the required files, set them for public read and collect their IDs (see outline example, below).
  1. Try to **directly download**[1]  the file using a GET request (again, shown in example).
  1. If you get a 404, it **most likely means** the file has a virus. 
  1. You can test this yourself using the `POC_phpinfo-metadata.jpg` infected image mentioned above.

#### Outline code example

This isn't meant to be copied into the production codebase. It should only serve as an approximate example of how you
might do it:

```ruby
session = GoogleDrive::Session.from_service_account_key('serviceAccount.json')
session.upload_from_file("tmp/POC_phpinfo-metadata.jpg", "POC_phpinfo-metadata.jpg", convert: false)
file = session.file_by_title("POC_phpinfo-metadata.jpg")
# This makes the file public
file.acl.push({type: "anyone", role: "reader"})
# You can get a shareable link that will open a preview and download page like this:
file.human_url

# If you now attempt to GET a direct download URL[1] like https://drive.google.com/uc?export=download&id=<file.id>, it
# will return a 404 if the file is infected. So, if you called: 

curl -I https://drive.google.com/uc?export=download&id=<file.id>

# You'd see the response code is 404.  An uninfected file called with this URL will generate a 302 (there's probably a
more up-to-date version of the download URL available but this one was sufficient).
```

[1] By **direct download URL** I mean a URL that points directly to the file in Google Drive. It is distinct from the
URL you get from `file.human_url` in that that link opens a preview page. Download is only one of the options on the
preview page and Drive does not scan for viruses until you attempt to download. 
