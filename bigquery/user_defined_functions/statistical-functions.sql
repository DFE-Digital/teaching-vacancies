  # Contains useful statistical functions that can be reused across multiple scheduled queries and views in BigQuery.
  # This script must be run in BigQuery for these functions to become available, and re-run to overwrite the available functions with any new version.
  #
  # Test whether there is a probability greater than a specified confidence_level that two probabilities of a Boolean-valued outcome calculated from two independent samples are different
  # e.g. test whether there is a >95% probability that the probabilities of a vacancy having a particular tag on a particular date and the same date in the previous year are different
  # x1,x2 are the numbers of true outcomes (e.g. heads, vacancies with tag) in each sample of size n1,n2
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.two_proportion_z_test`(confidence_level STRING, x1 INT64, n1 INT64, x2 INT64, n2 INT64)
  RETURNS BOOL AS (
  # check whether we can approximate these binomial distributions as normal distributions - return NULL if we can't
  CASE
  WHEN x1 <= 5 THEN NULL
  WHEN (n1 - x1) <= 5 THEN NULL
  WHEN x2 <= 5 THEN NULL
  WHEN (n2 - x2) <= 5 THEN NULL
  ELSE
  # calculate the value of the test statistic
  ABS(
  SAFE_DIVIDE
    (
      (
        SAFE_SUBTRACT(SAFE_DIVIDE(x1,n1), SAFE_DIVIDE(x2,n2))
      ),
      SAFE.SQRT(
        SAFE_MULTIPLY(
          SAFE_MULTIPLY(
            SAFE_ADD(SAFE_DIVIDE(1,n1), SAFE_DIVIDE(1,n2)),
            SAFE_DIVIDE(SAFE_ADD(x1,x2), SAFE_ADD(n1,n2))
            ),
          SAFE_SUBTRACT(1,SAFE_DIVIDE(SAFE_ADD(x1,x2), SAFE_ADD(n1,n2)))
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
