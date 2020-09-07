SELECT
  *,
  #calculate the confidence intervals for these key rates, assuming a 95% confidence level (i.e. z=1.96), that they can be modelled as binomial distributions and that the normal distribution approximation can be applied.
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusivity_rate*(1-exclusivity_rate),
      feedback_available_this_AY_so_far)) AS exclusivity_rate_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusivity_rate_this_AY_so_far*(1-exclusivity_rate_this_AY_so_far),
      feedback_available_this_AY_so_far)) AS exclusivity_rate_confidence_interval_this_AY_so_far,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusive_hires_rate*(1-exclusive_hires_rate),
      feedback_available)) AS exclusive_hires_rate_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusive_hires_rate_this_AY_so_far*(1-exclusive_hires_rate_this_AY_so_far),
      feedback_available_this_AY_so_far)) AS exclusive_hires_rate_confidence_interval_this_AY_so_far,
  1.96*SAFE.SQRT(SAFE_DIVIDE(hires_rate_through_TV*(1-hires_rate_through_TV),
      feedback_available)) AS hires_rate_through_TV_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(hires_rate_through_TV_this_AY_so_far*(1-hires_rate_through_TV_this_AY_so_far),
      feedback_available_this_AY_so_far)) AS hires_rate_through_TV_confidence_interval_this_AY_so_far,
FROM (
  SELECT
    *,
    SUM(vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS vacancies_published_this_AY_so_far,
    SUM(feedback_available) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS feedback_available_this_AY_so_far,
    SUM(feedback_available) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS response_rate_this_AY_so_far,
    CAST(SUM(hires_rate_through_tv*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS hires_through_tv_this_AY_so_far,
    CAST(SUM(exclusive_hires_rate*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_hires_this_AY_so_far,
    CAST(SUM(exclusivity_rate*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_listings_this_AY_so_far,
    SUM(savings) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS savings_this_AY_so_far,
    SUM(raw_savings) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS raw_savings_this_AY_so_far,
    SUM(hires_through_tv) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS hires_through_tv_feedback_this_AY_so_far,
    SUM(exclusive_hires) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_hires_feedback_this_AY_so_far,
    SUM(exclusive_listings) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_listings_feedback_this_AY_so_far,
    SUM(hires_rate_through_tv*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS hires_rate_through_tv_this_AY_so_far,
    SUM(exclusive_hires_rate*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_hires_rate_this_AY_so_far,
    SUM(exclusivity_rate*vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusivity_rate_this_AY_so_far,
    SAFE_DIVIDE(SUM(hires_through_tv) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(feedback_available) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_hires_rate_through_tv_this_AY_so_far,
    SAFE_DIVIDE(SUM(exclusive_hires) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(feedback_available) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_exclusive_hires_rate_this_AY_so_far,
    SAFE_DIVIDE(SUM(exclusive_listings) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(feedback_available) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_exclusivity_rate_this_AY_so_far,
  FROM (
    SELECT
      month,
      AY_beginning,
      SUM(vacancies_published) AS vacancies_published,
      SUM(feedback_available) AS feedback_available,
      SAFE_DIVIDE(SUM(feedback_available),
        SUM(vacancies_published)) AS response_rate,
      # Extrapolations from hiring staff feedback to estimates of total numbers of vacancies which were hires, exclusive etc, normalised by category (teacher,leadership,teaching_assistant or NULL)
      CAST(SUM(hires_rate_through_tv*vacancies_published) AS INT64) AS hires_through_tv,
      CAST(SUM(exclusive_hires_rate*vacancies_published) AS INT64) AS exclusive_hires,
      CAST(SUM(exclusivity_rate*vacancies_published) AS INT64) AS exclusive_listings,
      SUM(exclusive_hires_rate*vacancies_published*
      IF
        (category IN ("teacher",
            "leadership"),
          1200,
          0)) AS savings,
      #assume that only teachers and leadership exclusive hires save schools £1200/vacancy, and that other vacancies do not
      SAFE_DIVIDE(SUM(exclusive_hires),
        SUM(feedback_available))*SUM(vacancies_published)*1200 AS raw_savings,
      #estimate of savings, assuming all categories of vacancy behave the same and save schools the same amount of money
      # Extrapolations from hiring staff feedback to estimates of total numbers of vacancies which were hires, exclusive etc, unnormalised (i.e. assuming all categories of vacancy behave the same)
      SUM(hires_through_tv) AS hires_through_tv_feedback,
      SUM(exclusive_hires) AS exclusive_hires_feedback,
      SUM(exclusive_listings) AS exclusive_listings_feedback,
      #Extrapolations from hiring staff feedback to estimates of the overall proportion of vacancies which were hires, exclusive etc, normalised by category
      SUM(hires_rate_through_tv*vacancies_published)/SUM(vacancies_published) AS hires_rate_through_tv,
      SUM(exclusive_hires_rate*vacancies_published)/SUM(vacancies_published) AS exclusive_hires_rate,
      SUM(exclusivity_rate*vacancies_published)/SUM(vacancies_published) AS exclusivity_rate,
      #Extrapolations from hiring staff feedback to estimates of the overall proportion of vacancies which were hires, exclusive etc, unnormalised (i.e. assuming all categories of vacancy behave the same)
      SAFE_DIVIDE(SUM(hires_through_tv),
        SUM(feedback_available)) AS raw_hires_rate_through_tv,
      SAFE_DIVIDE(SUM(exclusive_hires),
        SUM(feedback_available)) AS raw_exclusive_hires_rate,
      SAFE_DIVIDE(SUM(exclusive_listings),
        SUM(feedback_available)) AS raw_exclusivity_rate,
    FROM (
      SELECT
        *,
        #calculate various metrics which are proportions of other metrics. SAFE_DIVIDE handles the legitimate cases where the denominator is zero, passing null instead of failing in these cases.
        SAFE_DIVIDE(feedback_available,
          vacancies_published) AS response_rate,
        SAFE_DIVIDE(hires_through_tv,
          feedback_available) AS hires_rate_through_tv,
        SAFE_DIVIDE(exclusive_hires,
          feedback_available) AS exclusive_hires_rate,
        SAFE_DIVIDE(exclusive_listings,
          feedback_available) AS exclusivity_rate,
      FROM (
        SELECT
          DATE_TRUNC(publish_on,MONTH) AS month,
          DATE_ADD(DATE_TRUNC(DATE_SUB(publish_on, INTERVAL 8 MONTH),YEAR),INTERVAL 8 MONTH) AS AY_beginning,
          #the 1st September of the academic year this month is in
          category,
          COUNT(*) AS vacancies_published,
          COUNTIF(hired_status IS NOT NULL
            AND listed_elsewhere IS NOT NULL) AS feedback_available,
          COUNTIF(hired_status="hired_tvs") AS hires_through_tv,
          COUNTIF(hired_status IN ("hired_tvs")
            AND listed_elsewhere IN ("not_listed",
              "listed_free")) AS exclusive_hires,
          COUNTIF(listed_elsewhere IN ("not_listed",
              "listed_free")) AS exclusive_listings
        FROM
          `teacher-vacancy-service.production_dataset.vacancies_published`
        GROUP BY
          month,
          AY_beginning,
          category)
      WHERE
        month IS NOT NULL )
    GROUP BY
      month,
      AY_beginning ))
ORDER BY
  month ASC
