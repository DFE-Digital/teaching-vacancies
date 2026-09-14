# Notify shortlist pack spike

Date: 11 September 2026

## Scope

Investigate whether a hiring staff user can select a variable number of
shortlisted native Teaching Vacancies applications and send the application
PDFs to a hiring manager through GOV.UK Notify.

This investigation did not call the Notify API or send any email or applicant
data. All PDF and payload checks used synthetic data locally.

Uploaded application forms are outside the initial spike scope.

## Finding: file URLs are dynamic, the template shape is not

Notify generates a unique secure download URL for each uploaded file. Each URL
must replace a named placeholder that already exists in the Notify template.
The template language does not provide a loop over uploaded files.

The Notify API implementation accepts multiple top-level file values and
processes each one. It does not turn a collection of files into a collection of
links in one placeholder. Extra personalisation values that are not referenced
by the template do not become visible in the email.

This means a template cannot accept an arbitrary number of file links such as
3 on one request and 8 on another without one of the following compromises:

1. Define a fixed maximum number of file placeholders in the template.
2. Send multiple emails, each containing no more than that fixed maximum.
3. Send one combined PDF through one placeholder.

## Fixed-slot behaviour

Notify considers an empty string to be a supplied placeholder value and
renders it as empty content. The initial proposal is therefore to define 8
file placeholders. A share containing fewer than 8 applications will send
files in the populated slots and pass empty strings for the unused slots.

This is technically viable based on the current Notify template engine, but it
has limitations:

- it creates a hard maximum of 8 applications per share;
- optional content cannot contain another personalisation placeholder, so a
  whole labelled application row cannot be conditionally shown or hidden;
- the template must be kept in sync with the maximum supported by the
  application;
- aggregate request-size behaviour still needs validation before this can be
  recommended for production.

## Local PDF and payload measurements

The existing `JobApplicationPdfGenerator` was exercised with synthetic native
applications.

| Sample | One PDF | One Base64 file value | 12 PDFs | 12 Base64 file values |
| --- | ---: | ---: | ---: | ---: |
| Representative application | approximately 209 KB | approximately 279 KB | approximately 2.51 MB | approximately 3.35 MB |
| Large but valid application, including a 1,500-word statement and extensive synthetic history | approximately 415 KB | approximately 554 KB | approximately 4.98 MB | approximately 6.64 MB |

A locally constructed request containing 12 representative files was
approximately 3.34 MB as JSON.

Every individual sample is well below Notify's 2 MB per-file limit. The
installed Notify Ruby client enforces that limit independently for each file.
Neither the client nor the Notify API application source defines a maximum
number of dynamic file values, but these local checks cannot prove that a
3–7 MB HTTP request will pass through every part of Notify's production
infrastructure.

## Initial conclusion

Notify can create multiple secure file links, but it cannot render a truly
dynamic list of file links in a single email template.

The product has accepted an initial maximum of 8 selected applications per
share. A fixed 8-slot template is therefore the proposed Phase 1 solution.
The application should reject a selection of more than 8 with a clear error;
hiring staff can send additional batches if needed.

Before production use, the 8-file request still needs validation in a
controlled Notify test. If its aggregate size is rejected, proceed to the
combined-PDF part of the spike or report the Notify limitation, depending on
the measured failure.

No real Notify test should be performed without explicit approval, a
non-production template, a permitted test recipient, and synthetic data.

## Prototype implementation

The implemented flow is:

1. `GET #new` collects the hiring manager's email address.
2. `POST #review` validates the email and selection and displays the review
   page without sending anything.
3. `POST #create` revalidates the request and queues
   `Publishers::ShortlistShareMailer#shortlist` with `deliver_later`.
4. The queued mailer generates each native application PDF in memory and
   prepares it as a secure Notify file with email confirmation and one-week
   retention.

No shortlist-share database table or persisted PDF is used. The queued mailer
receives the vacancy ID, up to 8 application IDs, the recipient email, and the
publisher ID.

The dedicated Notify template ID is configured in
`Publishers::ShortlistShareMailer::TEMPLATE_ID`. The template must define these
personalisation placeholders:

- `((job_title))`
- `((organisation_name))`
- `((application_1))` through `((application_8))`

Unused application placeholders receive an empty string.
