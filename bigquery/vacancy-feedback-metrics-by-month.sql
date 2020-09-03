SELECT
  *,
  SAFE_DIVIDE(feedback_available, #calculate various metrics which are proportions of other metrics. SAFE_DIVIDE handles the legitimate cases where the denominator is zero, passing null instead of failing in these cases.
    vacancies_published) AS response_rate,
  SAFE_DIVIDE(hires_through_tv,
    feedback_available) AS hires_rate_through_tv,
  SAFE_DIVIDE(hires_through_tv_upperbound,
    feedback_available) AS hires_rate_through_tv_upperbound,
  SAFE_DIVIDE(exclusive_hires,
    feedback_available) AS exclusive_hires_rate,
  SAFE_DIVIDE(exclusive_hires_upperbound,
    feedback_available) AS exclusive_hires_rate_upperbound,
  SAFE_DIVIDE(exclusive_hires,feedback_available) AS exclusivity_rate
FROM (
  SELECT
    DATE_TRUNC(publish_on,MONTH) AS month,
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
    COUNTIF(listed_elsewhere IN ("not_listed")) AS exclusive_listings
  FROM
    `teacher-vacancy-service.production_dataset.vacancies_published`
  GROUP BY
    month)
WHERE
  month IS NOT NULL
ORDER BY
  month ASC
