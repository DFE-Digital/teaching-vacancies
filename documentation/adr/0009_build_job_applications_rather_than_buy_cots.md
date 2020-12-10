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

Starting from next year job seekers will be able to apply for jobs directly through the service web site. Delivering this new function to users requires a significant amount of change and opens up the question whether we should opt for a COTS (commercial of the shelf) Application Tracking solution or take on the development effort and build our internal one.

## Decision

TVS will build Job Application rather than purchasing an off the shelf solution

## Considerations and consequences

Both solutions present advantages and disadvantages, and we considered if these are relevant in Teaching Vacancies problem space. 

### Specific user needs

The purchase a third-party ATS solution trades fit for price. If the problem to solve is generic enough, a simple adoption of a COTS product can be cheaper than bespoke software. 
Teaching Vacancies does not fall in that category, and user research has shown how schools hiring staff and job seekers have very different needs (product, accessibility), and the amount of customisation requested would increase the cost without providing what the service needs.

It's worth mentioning the cost-saving result of purchasing an ATS solution is less effective when compared to building our version, because TVS wouldn't need to scale up the engineering headcount.

### Cumbersome integration

The integration of an external ATS with pre-existing Teaching Vacancies application is challenging to deliver and even more to maintain in case of change. 

* **Data:** The engineering team would have to maintain a complex integration with risks in reliability and security. Data would need to be transferred in both direction from TVS to the application tracking system and back

* **DSI:** Hiring staff use DfE Sign In to access the service, and we would have to find a way to have either integrate DSI accounts with the external ATS service or ask hiring staff users to use another account to access part of the service

* **Analytical platform:** by adopting an external software, Teaching Vacancies loses control on produced job applications data and its format; the service will require the engineering team to extract and transform information stored in the ATS as needed by our analytical platform

### Change resistance
Lack of ownership of the ATS tool and its data correlates directly to a lack of flexibility in being able to change any minor or major component of the application, and the engineering team would have to rework the integration with the ATS, incurring in unnecessary cost 

### Relevant Documents:

* [Investigation of ATS Market](https://docs.google.com/document/d/18FDhNALb7wm1bP7gy_ntYe4Jzojr2lYivBx8cOfsGkA/edit#heading=h.taad96349hw1 "Google Doc")
* [ATS prototypes](https://www.figma.com/file/jLky9ngDJ8MkdN986m6HfI/Sprint-68?node-id=0%3A1 "Figma")

* [ATS comparison](https://docs.google.com/spreadsheets/d/1cH0y3qDZHQz5fOmv879nh4MzibTnwu6pezoSKwI7sD8/edit#gid=0 "Google Sheet")
