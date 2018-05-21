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

#### Example with salary range

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

#### Example with exact salary (no range)


```json
{
  "@context": "http://schema.org",
  "@type": "JobPosting",
  "title": "History teacher",
  "jobBenefits": null,
  "datePosted": "2018-05-15T00:00:00+00:00",
  "description": "<p> <p>We are seeking to appoint an enthusiastic and talented teacher of History to join our established and highly effective Humanities department. The successful candidate will join a committed team of teachers who are passionate about engaging and inspiring young people in their learning across the whole ability range. We offer fantastic opportunities to learn from very experienced and highly effective colleagues whilst also developing and contributing your own ideas and approaches.</p> <p>The Humanities subjects are an improving strength at Washington Academy with an excellent uptake at Key Stage 4. This well-resourced department is housed in a purpose-built suite of rooms and benefits from a forward thinking and innovative team of staff. If you are interested in joining an excellent department and have the skills and qualities required, we would be delighted to hear from you.</p> <p>Proudly rated Good by Ofsted in all 4 categories we are a mixed 11-16 Academy in the heart of Washington’s community. The successful candidate will join Washington Academy at a pivotal point as it has recently become part of the Consilium Multi Academy Trust. This MAT of 8 schools based in the North West and North East of England provides excellent provision for students in similar socioeconomic contexts. This will provide abundant opportunity to work with other colleagues in an expanding and progressive professional community and a fantastic springboard for professional progression within this vibrant and forward looking group of academies.</p> <p>If you are seeking a challenging and highly rewarding position, enriching the lives of the students who attend Washington Academy and members of the local community, then we are keen to hear from you.</p> <p>Washington Academy is committed to safeguarding and promoting the welfare of young people and expects all staff and volunteers to share this commitment. This post is subject to Enhanced Disclosure procedures.</p> <p>If you know that you can contribute to moving our Academy forward during this important time of change and development in education and believe that you can bring something unique to the post then please visit our website www.washingtonacademy.co.uk for further details and an application pack. Applications should be submitted for the attention of the Principal, to Mrs L Foster at Foster.L@washingtonacademy.co.uk.</p> <p>Washington Academy, Spout Lane, Washington NE37 2AA</p> <p>Closing date: 09:00 Tuesday 22nd May 2018<br> Interview date: Friday 25th May 2018</p> <p>Visits to the Academy are being held on Friday 18th May by appointment only.  Please email Mrs L Foster if you would like to attend, please include a contact number. Unfortunately we are unable to offer alternative dates and times.</p> <p>PLEASE NOTE: If you have not been contacted by the morning of Wednesday 23rd May please assume that your application has been unsuccessful on this occasion.  We are unable to provide feedback on individual applications. Applications received after the closing time stated will not be considered.  We do not accept CV’s.</p></p>",
  "educationRequirements": null,
  "qualifications": null,
  "experienceRequirements": "<p> The successful teacher will: <ul> <li>spark creativity amongst our students</li> <li>quickly motivate and bond with our students</li> <li>maintain a strong focus on stretching and challenging our students to achieve above and beyond expectations</li> <li>have excellent organisational skills and ability to work as part of a highly successful team that have a real buzz and enthusiasm for teaching</li> <li>NQTs and experienced teachers welcome.</li>\n<br /></ul></p>",
  "employmentType": "FULL_TIME",
  "industry": "Education",
  "jobLocation": {
    "@type": "Place",
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "Washington",
      "addressRegion": "Tyne and Wear",
      "streetAddress": "Spout Lane",
      "postalCode": "NE37 2AA"
    }
  },
  "url": "https://teachingjobs.education.gov.uk/jobs/history-teacher-washington-academy",
  "baseSalary": {
    "@type": "MonetaryAmount",
    "currency": "GBP",
    "value": {
      "@type": "QuantitativeValue",
      "value": 22917,
      "unitText": "YEAR"
    }
  },
  "hiringOrganization": {
    "@type": "School",
    "name": "Washington Academy",
    "identifier": "144937"
  },
  "validThrough": "2018-05-22T00:00:00+00:00",
  "workHours": null
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
