SELECT
  *,
  #calculate the confidence intervals for these key rates,
  #assuming a 95% confidence level (i.e. z=1.96),
  #that they can be modelled as binomial distributions
  #and that the normal distribution approximation can be applied.
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusivity_rate_this_month*(1-exclusivity_rate_this_month),
      sample_size_this_AY_so_far)) AS exclusivity_rate_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusivity_rate_this_AY_so_far*(1-exclusivity_rate_this_AY_so_far),
      sample_size_this_AY_so_far)) AS exclusivity_rate_confidence_interval_this_AY_so_far,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusivity_rate_in_the_last_year*(1-exclusivity_rate_in_the_last_year),
      sample_size_in_the_last_year)) AS exclusivity_rate_confidence_interval_in_the_last_year,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusive_hires_rate_this_month*(1-exclusive_hires_rate_this_month),
      sample_size_this_month)) AS exclusive_hires_rate_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusive_hires_rate_this_AY_so_far*(1-exclusive_hires_rate_this_AY_so_far),
      sample_size_this_AY_so_far)) AS exclusive_hires_rate_confidence_interval_this_AY_so_far,
  1.96*SAFE.SQRT(SAFE_DIVIDE(exclusive_hires_rate_in_the_last_year*(1-exclusive_hires_rate_in_the_last_year),
      sample_size_in_the_last_year)) AS exclusive_hires_rate_confidence_interval_in_the_last_year,
  1.96*SAFE.SQRT(SAFE_DIVIDE(hires_rate_through_TV_this_month*(1-hires_rate_through_TV_this_month),
      sample_size_this_month)) AS hires_rate_through_TV_confidence_interval,
  1.96*SAFE.SQRT(SAFE_DIVIDE(hires_rate_through_TV_this_AY_so_far*(1-hires_rate_through_TV_this_AY_so_far),
      sample_size_this_AY_so_far)) AS hires_rate_through_TV_confidence_interval_this_AY_so_far,
  1.96*SAFE.SQRT(SAFE_DIVIDE(hires_rate_through_TV_this_AY_so_far*(1-hires_rate_through_TV_in_the_last_year),
      sample_size_in_the_last_year)) AS hires_rate_through_TV_confidence_interval_in_the_last_year,
FROM (
  SELECT
    *,
    #calculate the values of each metric over the period
    #from the preceding 1st September and the month on each row
    SUM(vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS vacancies_published_this_AY_so_far,
    SUM(sample_size_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sample_size_this_AY_so_far,
    SUM(sample_size_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS response_rate_this_AY_so_far,
    CAST(SUM(hires_rate_through_tv_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS hires_through_tv_this_AY_so_far,
    CAST(SUM(exclusive_hires_rate_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_hires_this_AY_so_far,
    CAST(SUM(exclusivity_rate_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_listings_this_AY_so_far,
    SUM(savings_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS savings_this_AY_so_far,
    SUM(raw_savings_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS raw_savings_this_AY_so_far,
    SUM(hires_through_tv_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS hires_through_tv_feedback_this_AY_so_far,
    SUM(exclusive_hires_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_hires_feedback_this_AY_so_far,
    SUM(exclusive_listings_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_listings_feedback_this_AY_so_far,
    SUM(hires_rate_through_tv_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS hires_rate_through_tv_this_AY_so_far,
    SUM(exclusive_hires_rate_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusive_hires_rate_this_AY_so_far,
    SUM(exclusivity_rate_this_month*vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exclusivity_rate_this_AY_so_far,
    SAFE_DIVIDE(SUM(hires_through_tv_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_hires_rate_through_tv_this_AY_so_far,
    SAFE_DIVIDE(SUM(exclusive_hires_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_exclusive_hires_rate_this_AY_so_far,
    SAFE_DIVIDE(SUM(exclusive_listings_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (PARTITION BY AY_beginning ORDER BY month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS raw_exclusivity_rate_this_AY_so_far,
    #calculate the values of each metric over the previous 11 months and the month on this row
    SUM(vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS vacancies_published_in_the_last_year,
    SUM(sample_size_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS sample_size_in_the_last_year,
    SUM(sample_size_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS response_rate_in_the_last_year,
    CAST(SUM(hires_rate_through_tv_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS INT64) AS hires_through_tv_in_the_last_year,
    CAST(SUM(exclusive_hires_rate_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_hires_in_the_last_year,
    CAST(SUM(exclusivity_rate_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS INT64) AS exclusive_listings_in_the_last_year,
    SUM(savings_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS savings_in_the_last_year,
    SUM(raw_savings_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS raw_savings_in_the_last_year,
    SUM(hires_through_tv_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS hires_through_tv_feedback_in_the_last_year,
    SUM(exclusive_hires_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS exclusive_hires_feedback_in_the_last_year,
    SUM(exclusive_listings_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS exclusive_listings_feedback_in_the_last_year,
    SUM(hires_rate_through_tv_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS hires_rate_through_tv_in_the_last_year,
    SUM(exclusive_hires_rate_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS exclusive_hires_rate_in_the_last_year,
    SUM(exclusivity_rate_this_month*vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)/SUM(vacancies_published_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS exclusivity_rate_in_the_last_year,
    SAFE_DIVIDE(SUM(hires_through_tv_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)) AS raw_hires_rate_through_tv_in_the_last_year,
    SAFE_DIVIDE(SUM(exclusive_hires_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)) AS raw_exclusive_hires_rate_in_the_last_year,
    SAFE_DIVIDE(SUM(exclusive_listings_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),
      SUM(sample_size_this_month) OVER (ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)) AS raw_exclusivity_rate_in_the_last_year,
  FROM (
    SELECT
      month,
      AY_beginning,
      SUM(vacancies_published) AS vacancies_published_this_month,
      SUM(sample_size) AS sample_size_this_month,
      SAFE_DIVIDE(SUM(sample_size),
        SUM(vacancies_published)) AS response_rate_this_month,
      #Extrapolations from hiring staff feedback to estimates of total numbers of
      #vacancies which were hires, exclusive etc,
      #normalised by category (teacher,leadership,teaching_assistant or NULL)
      CAST(SUM(hires_rate_through_tv*vacancies_published) AS INT64) AS hires_through_tv_this_month,
      CAST(SUM(exclusive_hires_rate*vacancies_published) AS INT64) AS exclusive_hires_this_month,
      CAST(SUM(exclusivity_rate*vacancies_published) AS INT64) AS exclusive_listings_this_month,
      #assume that only teachers and leadership exclusive hires save schools
      #£1200/vacancy, and that other vacancies do not
      SUM(exclusive_hires_rate*vacancies_published*
      IF
        (category IN ("teacher",
            "leadership"),
          1200,
          0)) AS savings_this_month,
      #estimate of savings, assuming all categories of vacancy
      #behave the same and save schools the same amount of money
      SAFE_DIVIDE(SUM(exclusive_hires),
        SUM(sample_size))*SUM(vacancies_published)*1200 AS raw_savings_this_month,
      #Extrapolations from hiring staff feedback to estimates of total numbers
      #of vacancies which were hires, exclusive etc, unnormalised
      #(i.e. assuming all categories of vacancy behave the same)
      SUM(hires_through_tv) AS hires_through_tv_reported_this_month,
      SUM(exclusive_hires) AS exclusive_hires_reported_this_month,
      SUM(exclusive_listings) AS exclusive_listings_reported_this_month,
      #Extrapolations from hiring staff feedback to estimates of
      #the overall proportion of vacancies which were hires, exclusive etc,
      #normalised by category
      SUM(hires_rate_through_tv*vacancies_published)/SUM(vacancies_published) AS hires_rate_through_tv_this_month,
      SUM(exclusive_hires_rate*vacancies_published)/SUM(vacancies_published) AS exclusive_hires_rate_this_month,
      SUM(exclusivity_rate*vacancies_published)/SUM(vacancies_published) AS exclusivity_rate_this_month,
      #Extrapolations from hiring staff feedback to estimates of
      #the overall proportion of vacancies which were hires, exclusive etc,
      #unnormalised (i.e. assuming all categories of vacancy behave the same)
      SAFE_DIVIDE(SUM(hires_through_tv),
        SUM(sample_size)) AS raw_hires_rate_through_tv_this_month,
      SAFE_DIVIDE(SUM(exclusive_hires),
        SUM(sample_size)) AS raw_exclusive_hires_rate_this_month,
      SAFE_DIVIDE(SUM(exclusive_listings),
        SUM(sample_size)) AS raw_exclusivity_rate_this_month,
    FROM (
      SELECT
        *,
        #calculate various metrics which are proportions of other metrics.
        #SAFE_DIVIDE handles the legitimate cases where the denominator is
        #zero, passing null instead of failing in these cases.
        SAFE_DIVIDE(sample_size,
          vacancies_published) AS response_rate,
        SAFE_DIVIDE(hires_through_tv,
          sample_size) AS hires_rate_through_tv,
        SAFE_DIVIDE(exclusive_hires,
          sample_size) AS exclusive_hires_rate,
        SAFE_DIVIDE(exclusive_listings,
          sample_size) AS exclusivity_rate,
      FROM (
        SELECT
          DATE_TRUNC(publish_on,MONTH) AS month,
          #the 1st September of the academic year this month is in
          DATE_ADD(DATE_TRUNC(DATE_SUB(publish_on, INTERVAL 8 MONTH),YEAR),INTERVAL 8 MONTH) AS AY_beginning,
          category,
          COUNT(*) AS vacancies_published,
          COUNTIF(hired_status IS NOT NULL
            AND listed_elsewhere IS NOT NULL) AS sample_size,
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
