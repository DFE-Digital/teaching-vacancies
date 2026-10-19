module Publishers::DfeSignIn
  # Helpers for the jobs that export DSI users to BigQuery, to type each value for its column
  # (a TIMESTAMP as a Time, an INTEGER as an Integer), and to fail on a value that doesn't fit
  # rather than load it as NULL.
  module BigQueryExport
    include Parsing

    # The policy tag for the "masked" column in the BigQuery tables. This is used to mark the
    # column as containing sensitive data, so that access to it can be controlled separately
    # from the rest of the table.
    POLICY_TAG_MASKED = "projects/teacher-vacancy-service/locations/europe-west2/taxonomies/3297834668207407318/policyTags/6333608070544109307".freeze

    private

    # In UTC, as BigQuery hands a TIMESTAMP back. Raises on a value that isn't ISO 8601,
    # rather than storing it as NULL.
    def timestamp(value)
      Time.iso8601(value).utc if value.present?
    end

    # Base 10, so a leading zero isn't read as octal.
    def integer(value)
      Integer(value.to_s, 10) if value.present?
    end
  end
end
