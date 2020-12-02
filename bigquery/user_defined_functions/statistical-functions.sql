  # Contains useful statistical functions that can be reused across multiple scheduled queries and views in BigQuery.
  # This script must be run in BigQuery for these functions to become available, and re-run to overwrite the available functions with any new version.
  #
  # Test whether there is a probability greater than a specified confidence_level that two binomial distributions of the number of successes in a sample of trials have a different probability of success (normal approximation)
  # e.g. test whether there is a >95% probability that the probabilities of a vacancy having a particular tag on a particular date and the same date in the previous year are different
  # x1,x2 are the numbers of true outcomes (e.g. heads, vacancies with tag) in each sample of size n1,n2
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.two_proportion_z_test`(confidence_level STRING, successes_in_sample_1 INT64, trials_in_sample_1 INT64, successes_in_sample_2 INT64, trials_in_sample_2 INT64)
  RETURNS BOOL AS (
  # check whether we can approximate these binomial distributions as normal distributions - return NULL if we can't
  CASE
  WHEN successes_in_sample_1 <= 5 THEN NULL
  WHEN (trials_in_sample_1 - successes_in_sample_1) <= 5 THEN NULL
  WHEN successes_in_sample_2 <= 5 THEN NULL
  WHEN (trials_in_sample_2 - successes_in_sample_2) <= 5 THEN NULL
  ELSE
  # calculate the value of the test statistic
  ABS(
  SAFE_DIVIDE
    (
      (
        SAFE_SUBTRACT(SAFE_DIVIDE(successes_in_sample_1,trials_in_sample_1), SAFE_DIVIDE(successes_in_sample_2,trials_in_sample_2))
      ),
      SAFE.SQRT(
        SAFE_MULTIPLY(
          SAFE_MULTIPLY(
            SAFE_ADD(SAFE_DIVIDE(1,trials_in_sample_1), SAFE_DIVIDE(1,trials_in_sample_2)),
            SAFE_DIVIDE(SAFE_ADD(successes_in_sample_1,successes_in_sample_2), SAFE_ADD(trials_in_sample_1,trials_in_sample_2))
            ),
          SAFE_SUBTRACT(1,SAFE_DIVIDE(SAFE_ADD(successes_in_sample_1,successes_in_sample_2), SAFE_ADD(trials_in_sample_1,trials_in_sample_2)))
          )
        )
    )
    )
    >
    # compare this to the z-value for this confidence level, using precalculated values for these confidence levels
    CASE
    WHEN confidence_level="90%" THEN 1.645
    WHEN confidence_level="95%" THEN 1.96
    WHEN confidence_level="99%" THEN 2.576
    END
    END
    )
