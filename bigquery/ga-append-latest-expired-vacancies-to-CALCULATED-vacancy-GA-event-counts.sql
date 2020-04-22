SELECT
  vacancy.id,
  #unique vacancy ID from the Teaching Vacancies database
  vacancy.slug,
  #human readable dash-separated string that is probably also a unique vacancy ID (but can't trust this)
  CAST(vacancy.expiry_time AS TIMESTAMP) AS expiry_time,
  SUM( #series of SUMIF statements that turn various Google Analytics event configurations into counts of the total number of events that occurred on this vacancy's page
  IF
    (events.event_Action="vacancy_visited",
      events.Unique_Events,
      0)) AS views,
  SUM(
  IF
    (events.event_Action="vacancy_applied" #vacancy_applied is a pre-Q3 2019 event that was the same as action = vacancy_nextsteps AND label = get_more_information - left over from when we didn't record clicks on the mailto link or the school website URL on the listing page
      OR events.event_Action="vacancy_nextsteps"
      OR events.event_Action="document_download",
      #see comment below under document_download_clicks
      events.Unique_Events,
      0)) AS next_steps,
  SUM(
  IF
    (events.event_Action="vacancy_nextsteps"
      AND events.event_Label="website",
      events.Unique_Events,
      0)) AS website_clicks,
  SUM(
  IF
    ((events.event_Action="vacancy_nextsteps"
        AND events.event_Label="get_more_information")
      OR events.event_Action="vacancy_applied",
      #see comment above about vacancy_applied
      events.Unique_Events,
      0)) AS get_more_information_clicks,
  SUM(
  IF
    ((events.event_Action="vacancy_nextsteps"
        AND events.event_Label="document_download")
      OR events.event_Action="document_download",
      #on 22nd April document_download was moved into the event_action field from the event_label field to allow event_label to store the filename. This counts both events as document downloads.
      events.Unique_Events,
      0)) AS document_download_clicks,
  SUM(
  IF
    (events.event_Action="vacancy_nextsteps"
      AND events.event_Label="email",
      events.Unique_Events,
      0)) AS email_clicks,
  SUM(
  IF
    (events.event_Action="vacancy_shared",
      events.Unique_Events,
      0)) AS shares,
  SUM(
  IF
    (events.event_Action="vacancy_shared"
      AND events.event_Label="facebook",
      events.Unique_Events,
      0)) AS facebook_shares,
  SUM(
  IF
    (events.event_Action="vacancy_shared"
      AND events.event_Label="twitter",
      events.Unique_Events,
      0)) AS twitter_shares,
FROM
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
LEFT JOIN (
  SELECT
    SPLIT(SPLIT(Page_path_level_2,"/")[ #Convert the URL part from the Page_path_level_2 which comes in the form /slug into just the slug, which can be joined onto the slug field from the vacancies table in the database
    OFFSET
      (1)],"?")[ # throw away parameters from the end of the path - these tend to be things like A/B testing data which isn't useful here
  OFFSET
    (0)] AS slug,
    event_Action,
    Event_Label,
    Unique_Events
  FROM
    `teacher-vacancy-service.production_dataset.GA_events_on_vacancies_page`) AS events
ON
  vacancy.slug=events.slug #matches the vacancy slug from our database with the vacancy slug from the part of the page URL recorded in Google Analytics - this is the critical part of this query
WHERE
  vacancy.expiry_time < CURRENT_DATETIME #only obtain vacancies which have expired
  AND vacancy.expiry_time > CAST((
    SELECT
      MAX(expiry_time)
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_vacancy_GA_event_counts`) AS DATETIME) #only select vacancies that expired since we last ran this query
  AND status NOT IN ("trashed",
    "draft")
GROUP BY
  vacancy.id,
  vacancy.slug,
  vacancy.expiry_time
ORDER BY
  vacancy.expiry_time DESC
