**Date: 2020-11-16**

## Status

**Proposed**

## Parties Involved

 * Alex Bowen
 * Cesidio Di Landa
 * Christian Sutter
 * Connor McQuillan
 * David Mears
 * Davide Dippolito
 * Joe Hull

## Context

Teaching Vacancies is evolving the set of features available to its users.

Starting from next year, jobseekers will be able to apply for jobs directly through the service. Delivering this new functionality requires a significant amount of change and opens up the question of whether we should opt for a COTS (commercial off the shelf) Application Tracking solution, or take on the development effort and build it ourselves.

## Decision

Teaching Vacancies will build Job Application functionality rather than purchasing an off the shelf solution.

## Considerations and consequences

Both solutions present advantages and disadvantages, and we considered if these are relevant in the Teaching Vacancies problem space. 

### Specific user needs

The purchase of a third-party ATS solution trades fit for price. If the problem to solve is generic enough, a simple adoption of a COTS product could be cheaper than bespoke software. 
However, Teaching Vacancies does not fall into that category, and user research has shown that school hiring staff and jobseekers have very different needs (product, accessibility), and the amount of customisation required would increase the cost and still not be able to meet user needs. With any external SaaS product, we would also struggle to meet core requirements of the Service Standard, especially with regards to accessibility.

It's worth mentioning the cost-saving result of purchasing an ATS solution is less effective when compared to building our own version, because Teaching Vacancies wouldn't need to scale up the engineering headcount.

### Cumbersome integration

The integration of an external ATS with the existing Teaching Vacancies application is challenging to deliver and even more to maintain in case of change. 

* **Data:** The engineering team would have to maintain a complex integration with risks in reliability and security. A significant amount of data would need to be transferred in both directions between Teaching Vacancies and the ATS.

* **DSI and authorisation:** Hiring staff use DfE Sign In to access the service, and we would have to find a way to either integrate DSI accounts with the external ATS service, or ask hiring staff users to use another account to access part of the service. At the same time, ATS systems are predominantly designed for use by a single organisation (rather than a "white-label" solution for numerous organisations that we need) and authorisation would present a major stumbling block. 

* **Analytical platform:** By adopting external software, Teaching Vacancies loses control on job application data and its format; the service will require the engineering team to extract and transform information stored in the ATS to meet our analytical needs.

### Change resistance
Lack of ownership of the ATS tool and its data correlates directly to a lack of flexibility in being able to change any minor or major component of the application, and the engineering team would have to rework the integration with the ATS, incurring unnecessary cost.

### Relevant Documents:

* [Investigation of ATS Market](https://docs.google.com/document/d/18FDhNALb7wm1bP7gy_ntYe4Jzojr2lYivBx8cOfsGkA/edit#heading=h.taad96349hw1 "Google Doc")
* [ATS prototypes](https://www.figma.com/file/jLky9ngDJ8MkdN986m6HfI/Sprint-68?node-id=0%3A1 "Figma")

* [ATS comparison](https://docs.google.com/spreadsheets/d/1cH0y3qDZHQz5fOmv879nh4MzibTnwu6pezoSKwI7sD8/edit#gid=0 "Google Sheet")
