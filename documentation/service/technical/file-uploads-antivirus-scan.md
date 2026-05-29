# File uploads antivirus scan

We use "Microsoft Defender for Cloud" to scan malware and viruses in the service file uploads.

This happens asynchronously in Azure Storage and is configured at Azure Storage account level.

## Antivirus process for file uploads

```mermaid
sequenceDiagram
  actor User
  participant TV as Teaching Vacancies
  User ->> TV: Upload file in form
  participant Storage@{ "type" : "database" } as Azure Storage
  TV ->> Storage: Upload blob
  Storage ->>+ Microsoft Defender: Request malware scan
  Note over Storage,Microsoft Defender: Asynchronous
  Microsoft Defender -->>- Storage: Set scan result
  Note over Storage,Microsoft Defender: May take a while to appear
  TV -> TV: Wait 2 seconds
  critical Retrieves and Sets scan results
    TV ->> Storage: Fetch malware scan results
    Storage -->> TV: Blob with metadata tags
  option Scan results not available
    TV -> TV: Retry job with exponential wait
  option Scan results available
    critical acts on results
      TV -> TV: Record scan result in Blob
    option file is unsafe
      TV -> TV: Purge Attachment
      TV ->> User: Notify user
    end
  end
```

## Antivirus check process in our codebase

```mermaid
block-beta
columns 3
  attach(("Attach\nFile")) space:2
  block-beta
    columns 1
    blob>"ActiveStorage Blob"]
    block-beta
      columns 1
      concern>"MalwareScannable concern"]
      scanfetching["Scan result\nfetching"]
      space:1
      scanresult["Scan result\nrecording"]
    end
  end
  space:1
  block-beta
    columns 1
    job>"FetchMalwareScanResultJob"]
    block-beta
      columns 1
      handle>"Handle unsafe attachments\n(deletes and notifies)"]
      unsafeorg["Unsafe org attachment"]
      unsaferef["Unsafe reference document"]
    end
  end

  attach -- "creates" -->blob
  blob -- "includes" -->concern
  concern -- "enqueues on creation" -->job
  scanfetching -- "sets result" --> scanresult
  job -- "triggers & retrieves" --> scanfetching
  job -- "handles" --> handle
```

Based on the output of the AV scan result. The attachments will be purged, resources destroyed, notifications sent, etc (all handled by `FetchMalwareScanResultJob`).

Also user journeys will check/validate that the attachments are AV clean before allowing users to proceed/submit.
