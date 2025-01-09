require "dfe_sign_in/api"
require "google/cloud/bigquery"

module Publishers::DfeSignIn::BigQueryExport
  class Base
    include DfeSignIn::API
    include Publishers::DfeSignIn::Parsing

    POLICY_TAG_MASKED = "projects/teacher-vacancy-service/locations/europe-west2/taxonomies/3297834668207407318/policyTags/6333608070544109307".freeze

    attr_reader :dataset

    def initialize(bigquery: Google::Cloud::Bigquery.new)
      @dataset = bigquery.dataset(Rails.configuration.bigquery_dataset)
    end

    private

    def delete_table(table_name)
      table = dataset.table table_name
      return if table.nil?

      dataset.reload! if table.delete
    end
  end
end
