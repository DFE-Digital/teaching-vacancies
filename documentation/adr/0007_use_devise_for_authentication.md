# Use Devise for authentication

**Date: 2020-11-16**

## Status

**Decided**

## Parties Involved

 * Alex Bowen
 * Cesidio Di Landa
 * Christian Sutter
 * Connor McQuillan
 * David Mears
 * Davide Dippolito
 * Joe Hull

## Context

Teaching Vacancies will soon start to develop a new set of features which ultimately will allow job seekers to apply for jobs directly on the TVS website.

This feature constitutes an important milestone for the service and will require job seekers users to create accounts to manage their job applications. Account functionality will permit teachers to initiate web sessions on TVS website as well as manage their account (password resets, email verification and account closing).

## Options considered

| Name      | Link                                     | Notes                                                                                    |
| --------- | ---------------------------------------- | ---------------------------------------------------------------------------------------- |
| Devise    | https://github.com/heartcombo/devise     | Widely adopted in the Ruby on Rails community. Easily available documentation and features covering most TVS needs |
| Clearance | https://github.com/thoughtbot/clearance  | Easy to integrate and configure, not as feature rich as Devise                           |
| Authlogic | https://github.com/binarylogic/authlogic | Little support                                                                                       | 
| Rodauth   | https://github.com/jeremyevans/rodauth   | Scarcely adopted                                                                                      |

**Note:**

The team considered the pros and cons of adopting a "in house" build strategy opposed to buying and integrating with off the shelf solutions. You can read more about it [in this document](https://docs.google.com/document/d/1bhdvsP4EDoFVO3FAhH-0ECoBBS6xPjf8thzpD1ay3b0)
## Decision

TVS will adopt Devise as authentication library. 

## Considerations and consequences

Devise is the de facto standard solution for Ruby on Rails applications. It has been already successfully adopted by other teams within DfE
* https://github.com/DFE-Digital/apply-for-teacher-training
* https://github.com/DFE-Digital/childrens-social-care-placement
* https://github.com/DFE-Digital/npd-find-and-explore

It provides plug-in modules to better refine authentication options allowing storing encrypted passwords, support for Omniauth providers, passwords recovery and so on.

Given its modular structure, it's fairly straightforward to isolate code relative to authentication. This allows a painless transition to a different solution in case TVS would want to evaluate a SaaS option in case the department wants to adopt a more strategical approach to authentication for job seekers.
