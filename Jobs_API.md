# Teaching Jobs JSON API

[teachingjobs.education.gov.uk](teachingjobs.education.gov.uk)

Disclaimer: The Teaching Jobs JSON API is **read-only**.

## Properties

[schema]:http://schema.org/JobPosting 'schema.org'
[google]:https://developers.google.com/search/docs/data-types/job-posting 'schema.org'

:speech_balloon:: Can be improved/extended

:warning:: Mismatch with schema definition. Invalid.

:white_check_mark:: Fields indexed by google as part of the JobPosting definition

`incentive_compensation` and `responsibilities` are not currently utilised, but they do fit our captured information.

#### JobPosting

| | Type |  Description  | Status | [G][google] |
| --- | --- | --- | :---: | :---: |
 **title** | `Text` | The title of the job, for example _Teacher of English_  |  |  :white_check_mark:
 **jobBenefits** | `Text` | ~~Description of benefits associated with the job~~ Financial benefits, job training, continuing professional development and whether Special Educational Needs (SEN) allowances or Teaching and Learning Responsibility (TLR) payments are available. |  :warning:
 `*incentiveCompensation` | `Text` | Description of bonus and commission compensation aspects of the job. ([schema][schema]) | :warning:
 **datePosted** | `date` | Publication date for the job posting in [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format | | :white_check_mark:
 **description** | `Text` | ~~The full description of the job in HTML format. The description should be a complete representation of the job, including job responsibilities, qualifications, skills, working hours, education requirements, and experience requirements. The description can't be the same as the title~~ Duties and responsibilities involved in the role |  :warning: | :white_check_mark:
 `*responsibilities` | `Text` | Responsibilities associated with this role ([schema][schema]) | :warning:
 **educationRequirements** | `Text` | Educational background needed for the position ([schema][schema]) |
 **qualifications**  | `Text` | Specific qualifications required for this role ([schema][schema]) |
 **experienceRequirements**  | `Text` | Description of skills and experience needed for the position ([schema][schema]) |
 **employmentType** | `Text` | Type of employment (`PART_TIME` or `FULL_TIME`) | :speech_balloon: | :white_check_mark:
 **industry** | `Text` | The industry associated with the job position ([schema][schema]) |
 **jobLocation** | [Place](#place) | A geographic location associated with the job position | :speech_balloon: | :white_check_mark:
 **url** | `URL` |  URL of the  job post |
 **baseSalary** | [MonetaryAmount](#monetaryamount) | The actual base salary for the job, as provided by the employer | | :white_check_mark:
 **hiringOrganization** | [School](#school) | The school offering the job position | :speech_balloon: | :white_check_mark:
 **validThrough** | `Date` |  The date when the job posting will expire in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format | | :white_check_mark:
 **workHours**  | `Text` | ~~The typical working hours for this job (e.g. 1st shift, night shift, 8am-5pm)~~ Number of hours to be worked each week ([schema][schema]) | :warning:

#### Place

[http://schema.org/Place](http://schema.org/Place)

| | Type |  Description |
--- | --- | ---
adddress | [PostalAddress](#postaladdress) | The school's physical address


#### PostalAddress

[http://schema.org/PostalAddress](http://schema.org/PostalAddress)

| | Type | Description
--- | --- | ---
addressLocality | `Text` | The town that the school is located in
addressRegion | `Text` | The county that the school is located in
streetAddress | `Text` | The school's address
postalCode | `Text` | The postal code of the school


#### MonetaryAmount

[http://schema.org/MonetaryAmount](http://schema.org/MonetaryAmount)

| | Type | Description |
--- | --- | ---
currency | `Text` | The currency in which the salary amount is expressed (in 3-letter [ISO 4217](https://www.iso.org/iso-4217-currency-codes.html)) (default: `GBP`)
value | [QuantitativeValue](#quantitativevalue) | The salary value

#### QuantitativeValue

[http://schema.org/QuantitativeValue](http://schema.org/QuantitativeValue)

| | Type | Description |
--- | --- | ---
value  | `number` | A number specifying the salary amount (only set if not salary range is specified)
unitText | `Text` | The unit of time of the salary (default: `YEAR`)

**Case with salary range**

| | Type | Description
--- | --- | ---
minValue | `Number` | The salary lower value (only set if the salary is within a given range )
maxValue | `Number` | The salary upper value (only set if the salary is within a given range)
unitText | `Text` | The unit of time of the salary (default: `YEAR`)


#### School

[http://schema.org/School](http://schema.org/School)

| | Type |  Description |
--- |  --- | ---
name | `Text` |The name of the school
identifier | `Text` | The school urn


### Sample JSON response

```json
{
  "@context": "http://schema.org",
  "@type": "JobPosting",
  "title": "SCIENCE TEACHER – 1 Year Contract",
  "jobBenefits": null,
  "datePosted": "2018-05-15T00:00:00+00:00",
  "description": "<p>Please visit the link for full Job Description. </p>",
  "educationRequirements": "<p>High standard of Science teaching across the biological &amp; physical sciences.</p>",
  "qualifications": "<p>Qualified Teacher Status in one or more of the sciences.\n</p>",
  "experienceRequirements": "<p>Qualified Teacher Status in one or more of the sciences.\n<br />High standard of Science teaching across the biological &amp; physical sciences.\n<br />Sense of humour and enthusiasm\n<br />Ability to work as a member of a team.\n<br />Organisational skills and ability to meet deadlines.</p>",
  "employmentType": "FULL_TIME",
  "industry": "Education",
  "jobLocation": {
    "@type": "Place",
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "Crook",
      "addressRegion": "County Durham",
      "streetAddress": "Hall Lane Estate",
      "postalCode": "DL15 0QF"
    }
  },
  "url": "https://teachingjobs.education.gov.uk/jobs/science-teacher-1-year-contract",
  "baseSalary": {
    "@type": "MonetaryAmount",
    "currency": "GBP",
    "value": {
      "@type": "QuantitativeValue",
      "minValue": 22917,
      "maxValue": 38633,
      "unitText": "YEAR"
    }
  },
  "hiringOrganization": {
    "@type": "School",
    "name": "Parkside Academy",
    "identifier": "137903"
  },
  "validThrough": "2018-05-21T00:00:00+00:00",
  "workHours": ""
}
```

### Concerns

The following captured fields are not made available via JSON as they don't map to the JobPosting schema definition.

| Field |
| :----: |
| starts_on |
|  ends_on |
| subject |
| pay_scale |
| leadership |
| contact_email |
