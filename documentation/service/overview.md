# Service Overview

> Teaching Vacancies is a free job-listing service from the Department for Education.
>
> Teachers can search and apply for jobs at schools or trusts in England, save jobs and set up job alerts.

## C4 System Context Diagram
How does Teaching Vacancies fall within GovUK and Department for Education scopes?

How does integrate with People and other software systems?

```mermaid
C4Context
  title System Context diagram for Teaching Vacancies Service
  Person(publisher, "Publisher/Hiring staff", "A member of the public, employee for a<br>school/group/LA<br>that lists and manages vacancies.")
  Person(jobseeker, "Jobseeker", "A member of the public, job candidate that<br>applies for listed vacancies.")

  Enterprise_Boundary(atsorgs, "External ATS orgs") {
    System_Ext(ATS, "ATS", "Recruitment and<br>Applicant Tracking Systems")
  }

  Enterprise_Boundary(govuk, "GovUK") {
    System_Ext(Notify, "Gov UK<br>Notify", "Mailer system for<br>Email communications")
    System_Ext(OneLogin, "Gov UK<br>One Login", "User authentication system<br>for the public")

    Enterprise_Boundary(dfe, "Department for Education") {
      System(TV, "Teaching Vacancies", "Allows publishers to list and manage job vacancies and their applications.<br> Allows jobseekers to apply for listed vacancies.")
      System_Ext(DfESignIn, "DfE Sign In", "User authentication system for<br>education organisation publishers/hiring staff")
      SystemDb_Ext(GIAS, "GIAS<br>Get Information About Schools", "Stores the information about schools,<br> their publishers, school groups, etc")
    }

    Enterprise_Boundary(dwp, "DWP<br>Department of Work and Pensions") {
      System_Ext(FindAJob, "Find a Job Service", "Service to search and<br>apply for jobs")
    }
  }

  BiRel(publisher, TV, "Posts/Manages<br>vacancies")
  BiRel(jobseeker, TV, "Lists/Applies<br>for vacancies")

  Rel(publisher, DfESignIn, "Signs through")
  Rel(jobseeker, OneLogin, "Signs through")

  BiRel(OneLogin, TV, "Jobseeker<br>user management")
  BiRel(DfESignIn, TV, "Publisher user and<br>org. access management")


  Rel(GIAS, TV, "Provides orgs information", "CSV pulls")
  Rel(TV, FindAJob, "Exports vacancies", "CSV through SFTP")

  Rel(ATS, TV, "NEW:<br>Posts/Manages vacancies", "REST API")
  Rel(TV, ATS, "LEGACY:<br>Pulls vacancies", "XML/APIs")
  Rel(TV, Notify, "Sends emails<br>to users", "API" )

  UpdateLayoutConfig($c4ShapeInRow="2", $c4BoundaryInRow="1")
  UpdateRelStyle(publisher, TV, $offsetX="-170", $offsetY="-220")
  UpdateRelStyle(publisher, DfESignIn, $offsetX="-110", $offsetY="-150")
  UpdateRelStyle(ATS, TV, $offsetX="-250", $offsetY="-40")
  UpdateRelStyle(TV, ATS, $offsetY="-40")
  UpdateRelStyle(jobseeker, OneLogin, $offsetX="-40", $offsetY="-30")
  UpdateRelStyle(jobseeker, TV, $offsetX="-150", $offsetY="-220")
  UpdateRelStyle(OneLogin, TV, $offsetX="30", $offsetY="-70")
  UpdateRelStyle(TV, Notify, $offsetX="-90", $offsetY="-70")
  UpdateRelStyle(TV, FindAJob, $offsetX="-50", $offsetY="-40")
  UpdateRelStyle(GIAS, TV, $offsetX="-30", $offsetY="100")
```
