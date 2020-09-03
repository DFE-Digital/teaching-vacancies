SELECT
  month,
  SUM(vacancies_published) AS vacancies_published,
  SUM(feedback_available) AS feedback_available,
  SAFE_DIVIDE(SUM(feedback_available),SUM(vacancies_published)) AS response_rate,

  # Extrapolations from hiring staff feedback to estimates of total numbers of vacancies which were hires, exclusive etc, normalised by category (teacher,leadership,teaching_assistant or NULL)
  CAST(SUM(hires_rate_through_tv*vacancies_published) AS INT64) AS hires_through_tv,
  CAST(SUM(hires_rate_through_tv_upperbound*vacancies_published) AS INT64) AS hires_through_tv_upperbound,
  CAST(SUM(exclusive_hires_rate*vacancies_published) AS INT64) AS exclusive_hires,
  CAST(SUM(exclusive_hires_rate_upperbound*vacancies_published) AS INT64) AS exclusive_hires_upperbound,
  CAST(SUM(exclusivity_rate*vacancies_published) AS INT64) AS exclusive_listings,
  SUM(exclusivity_rate*vacancies_published*IF(category IN ("teacher","leadership"),1200,0)) AS savings, #assume that only teachers and leadership exclusive hires save schools £1200/vacancy, and that other vacancies do not
  
  SAFE_DIVIDE(SUM(exclusive_listings),SUM(feedback_available))*SUM(vacancies_published)*1200 AS raw_savings, #estimate of savings, assuming all categories of vacancy behave the same and save schools the same amount of money

  # Extrapolations from hiring staff feedback to estimates of total numbers of vacancies which were hires, exclusive etc, unnormalised (i.e. assuming all categories of vacancy behave the same)
  SUM(hires_through_tv) AS hires_through_tv_feedback,
  SUM(hires_through_tv_upperbound) AS hires_through_tv_upperbound_feedback,
  SUM(exclusive_hires) AS exclusive_hires_feedback,
  SUM(exclusive_hires_upperbound) AS exclusive_hires_upperbound_feedback,
  SUM(exclusive_listings) AS exclusive_listings_feedback,

  #Extrapolations from hiring staff feedback to estimates of the overall proportion of vacancies which were hires, exclusive etc, normalised by category
  SUM(hires_rate_through_tv*vacancies_published)/SUM(vacancies_published) AS hires_rate_through_tv,
  SUM(hires_rate_through_tv_upperbound*vacancies_published)/SUM(vacancies_published) AS hires_rate_through_tv_upperbound,
  SUM(exclusive_hires_rate*vacancies_published)/SUM(vacancies_published) AS exclusive_hires_rate,
  SUM(exclusive_hires_rate_upperbound*vacancies_published)/SUM(vacancies_published) AS exclusive_hires_rate_upperbound,
  SUM(exclusivity_rate*vacancies_published)/SUM(vacancies_published) AS exclusivity_rate,

  #Extrapolations from hiring staff feedback to estimates of the overall proportion of vacancies which were hires, exclusive etc, unnormalised (i.e. assuming all categories of vacancy behave the same)
  SAFE_DIVIDE(SUM(hires_through_tv),SUM(feedback_available)) AS raw_hires_rate_through_tv,
  SAFE_DIVIDE(SUM(hires_through_tv_upperbound),SUM(feedback_available)) AS raw_hires_rate_through_tv_upperbound,
  SAFE_DIVIDE(SUM(exclusive_hires),SUM(feedback_available)) AS raw_exclusive_hires_rate,
  SAFE_DIVIDE(SUM(exclusive_hires_upperbound),SUM(feedback_available)) AS raw_exclusive_hires_rate_upperbound,
  SAFE_DIVIDE(SUM(exclusive_listings),SUM(feedback_available)) AS raw_exclusivity_rate,

FROM (
  SELECT
    *,
    #calculate various metrics which are proportions of other metrics. SAFE_DIVIDE handles the legitimate cases where the denominator is zero, passing null instead of failing in these cases.
    SAFE_DIVIDE(feedback_available,
      vacancies_published) AS response_rate,
    SAFE_DIVIDE(hires_through_tv,
      feedback_available) AS hires_rate_through_tv,
    SAFE_DIVIDE(hires_through_tv_upperbound,
      feedback_available) AS hires_rate_through_tv_upperbound,
    SAFE_DIVIDE(exclusive_hires,
      feedback_available) AS exclusive_hires_rate,
    SAFE_DIVIDE(exclusive_hires_upperbound,
      feedback_available) AS exclusive_hires_rate_upperbound,
    SAFE_DIVIDE(exclusive_listings,
      feedback_available) AS exclusivity_rate
  FROM (
    SELECT
      DATE_TRUNC(publish_on,MONTH) AS month,
      category,
      COUNT(*) AS vacancies_published,
      COUNTIF(hired_status IS NOT NULL
        AND listed_elsewhere IS NOT NULL) AS feedback_available,
      COUNTIF(hired_status="hired_tvs") AS hires_through_tv,
      COUNTIF(hired_status IN ("hired_dont_know",
          "hired_tvs")) AS hires_through_tv_upperbound,
      COUNTIF(hired_status IN ("hired_tvs")
        AND listed_elsewhere IN ("not_listed",
          "listed_free")) AS exclusive_hires,
      COUNTIF(hired_status IN ("hired_dont_know",
          "hired_tvs")
        AND listed_elsewhere IN ("not_listed",
          "listed_free",
          "listed_dont_know")) AS exclusive_hires_upperbound,
      COUNTIF(listed_elsewhere IN ("not_listed","listed_free")) AS exclusive_listings
    FROM
      `teacher-vacancy-service.production_dataset.vacancies_published`
    GROUP BY
      month,
      category)
  WHERE
    month IS NOT NULL )
GROUP BY
  month
ORDER BY
  month ASC
