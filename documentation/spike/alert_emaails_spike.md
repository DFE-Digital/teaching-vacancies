# Alert Email

## Background
We currently send a huge number job alerts and we want to review this feature in anticipation of an increase once we expand into FE.

We have no visibility on the number of job alert emails that are actually opened.

## Desired outcomes
Have a stable alert emails jobs memory and comptutationally wise even after the increased number of live vacancies.

## Proposed suggestions
After reviewing different alternatives to the issue at hand, the following set of suggestions seems to best fit TV.
They could be applied sequentially without having to commit to a massive task at once.

### Add alert email jobs monitoring
This is to be able to observe the health of the service. We should monitor:
- time taken to complete whole job
- memory used to complete whole job
- list the N slowest subscriptions to process
- setup alerting when certain metric's threshold are reached

### Pre-computed subscription.vacancies_matching
Split subscription.vacancies_matching form email sending to have a predictable behaviour for the email sending even at peak times.

The output of the pre-computation job should be optimized for retrieval so that the subsequent email sending job is as fast as possible.

### Email content optimisation
At the moment we could be loading up to 500 matching vacancies to send 1 email. This high number of vacancies matching could be reduced to 10-20 matches and the remaining matches could be accessed by adding a link to vacancy search page with the subscription.search_criterias filled in.

### Caching
The subscription.vacancies_matching pre-computation job output could be cached so that accessing the vacancy search page for a subscription.search_criteria does not impact the service when user following the link from their job alert email.
Access on the link from an old email should be fine as long as the subscription is live (ie not soft/hard deleted). When the subscription has expired the service would perform fresh vacancy search operation.

### Subscription retention policy
We could soft delete any subscription that did not get its job alert email opened in that the last X time period.
This would has 2 main benefits:
- reducing the load for pre-computation and send email jobs
- provided analytics to email opening rate for business stakeholders.
Hard deletion is already in place.

### Query optimisation
Query optimisation of various degrees of difficulty could be further investgated to improve performance, here are some suggestions to that end:
1. subscription.search_criteria grouping
grouped by similar / identical subscription.search_criteria; the vacancies_matching ouput could be cached and the pre-computation skipped altogether [effort easy]

2. simplify polygons for faster search results [effort medium]
Change location search to use a center point with radius instead of polygon search.
IE we take the center of the city, borough, region instead of the details entity borders.

3. delving into SQL/ruby query optimisation [effort medium]
Search criterias are stored as json object and the filtering is perform in memory with ruby.
PG support querying with fields stored as json
[PG datatype json](https://www.postgresql.org/docs/17/datatype-json.html)
   
4. use a third party tool (ElasticSearc || Solr) 
the pre computation of the vacancy matching. This would be significant task to migrate. [effort hard]


## Suggestion rationale

After reviewing the codebase, the data available, the upcoming work and business need, the key element of the proposed suggestions is about spliting the sending alert emails from the computation of the vacancies matching subscriptions search_criterias.

There no need for real time or near real time alerting, we are sending emails every day / week. So we would perform the pre computation over night to have the matches ready when its time to send the emails.
A pre computation output cache of 24h seems appropriate here.

Even though the code base around vacancy matching or VacancySearch in general is quite complex at the moment and migrating all to a third party tools and keep feature parity could be a lengthy task for the team. That not even mentioning add new dependency to the service tech stack that would need production level deployment, maintenance and monitoring.
As opposed to extracting the current computation into its own job. This should be fairly quick to acheive for the team. This is preferable as the FE work is coming up soon. 
Also the proposed suggestions opts for a staged approach that can be driven by the job monitoring metrics.

Regarding job fallback, we can reuse the alertrun concept to handle email failure. 
For the pre-compute job, in the eventuality of an error we reuse the old cache while the team investigates the cause of the error.

Pre computation output could be stored in the db.

After a few weeks we should have an accurate performance profile for the jobs and better spot when metrics start degrading. At that point we could choose which task to action.

Regarding soft delete the retention policy, to be able to update the subscriptions `email_last_opened_at` datetime we would to have a tracking feature in the email. So that when the jobseeker opens the email a request is sent the TV that would enable us to update that field.
We could use a tracking pixel added to an HTML email, but that would require migrating the alert email to away from GOV.UK Notify to another platform capable of sending HTML emails.


## Questions
1. Is there any legal restriction in using a tracking feature in the email?
2. [UCD] email conent optimisation, will jobseekers prefer the proposed email content format?
   if not, does ordering the vacancies matching by the most important criteria makes the proposed email content format more attractive?
