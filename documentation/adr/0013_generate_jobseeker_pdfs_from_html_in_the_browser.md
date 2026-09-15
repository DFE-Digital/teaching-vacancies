# Generate jobseeker-facing PDFs from HTML pages in the browser where possible

**Date: 2026-09-14**

## Status

**Decided**

## Context and Problem Statement

The service produces PDF documents for two very different audiences:

- **Jobseekers and other public users**, for example a jobseeker downloading a copy of their
  submitted application or previewing an application form.
- **Publishers (hiring staff)**, for example downloading a job application, a reference, a
  self-disclosure form or a message history, or bulk downloading applications for a vacancy.

All of these PDFs are currently generated on the server with
[Prawn](https://github.com/prawnpdf/prawn) (`app/services/*_pdf_generator.rb`).

Prawn has served us well and we have seen no memory problems with it. The concern is not memory
but **request thread time**. Generating a PDF is CPU-bound work that runs inside a web request, and
each Puma worker has a small, fixed number of threads (`RAILS_MAX_THREADS`, 3 by default). While a
thread is building a PDF it cannot serve any other request.

Jobseeker accounts are free and self-service, so anybody can create one. An attacker, or a group of
them, could repeatedly request PDF downloads to keep every web thread busy generating documents.
The service would then stop responding to everyone else. PDF endpoints are therefore a cheap and
effective vector for a Distributed Denial of Service (DDoS) attack. Rate limiting with Rack::Attack
reduces the risk from a single IP address, but it is much less effective against requests spread
across many addresses and accounts.

Most jobseeker-facing documents are already rendered as HTML pages in the service, with print
styles (`govuk-!-display-none-print`) that hide navigation and buttons. Browsers can print these
pages or save them as PDFs without any server-side work beyond serving the page.

Should we keep generating jobseeker-facing PDFs on the server?

## Decision Drivers

- Protect the availability of the service: web threads must not be exhaustible by unauthenticated
  or self-registered users requesting expensive documents.
- Reduce the attack surface available to anyone who can create a jobseeker account.
- Avoid maintaining two representations (an HTML page and a Prawn layout) of the same document
  where one would do.
- Publishers need documents that cannot be produced by a browser, in particular ZIP archives
  bundling several PDFs for bulk downloads.

## Considered Options

- Keep generating all PDFs on the server with Prawn.
- Move all PDF generation to the browser, from HTML pages.
- Generate jobseeker-facing PDFs in the browser from HTML pages where possible, and keep Prawn for
  publisher-facing PDFs.

## Decision Outcome

We will generate jobseeker-facing and other public PDFs **in the browser, from HTML pages, wherever
possible**. The server renders the page as HTML with suitable print styles, and the jobseeker uses
the browser's print or "Save as PDF" function. New jobseeker-facing PDF features should follow this
approach, and existing server-side jobseeker downloads (such as the submitted application download
and form previews) should move to it when they are next reworked.

We will **keep server-side generation with Prawn for publishers**. Publishers are a known,
authenticated group, signed in through DfE Sign In and tied to an organisation, so the risk of
abuse is far lower.

We **cannot remove server-side generation completely**. Some publisher features bundle several
generated documents into a single ZIP file, for example bulk downloading job applications
(`JobApplicationZipBuilder`) or exporting candidate data with references and self-disclosures
(`ExportCandidateDataService`). A browser cannot produce these archives from HTML pages, so the
PDFs inside them have to be generated on the server.

### Positive Consequences

- Jobseekers can no longer tie up web threads by requesting PDFs, which removes an easy DDoS
  vector from the public side of the service.
- Less CPU load on the web servers from jobseeker traffic.
- One representation of each jobseeker-facing document (the HTML page) to build, test and keep
  accessible, instead of an HTML page and a separate Prawn layout.
- Jobseekers get a document that matches what they see on screen.

### Negative Consequences

- Less control over the final PDF: layout, page breaks, headers and footers depend on the browser
  and the user's print settings.
- Jobseekers need one more step (print, then save as PDF) instead of a direct download link, and
  the content needs clear guidance on how to do it.
- Two approaches to PDF generation coexist in the codebase, so developers need to know which one
  to use for each audience.
- Publisher PDF endpoints, including bulk ZIP downloads, remain server-side and still consume web
  threads. They rely on publisher authentication and rate limiting for protection, and could be
  moved to background jobs if that becomes necessary.
