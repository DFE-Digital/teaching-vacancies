module Publishers
  class StatisticsController < BaseController
    private

    def equal_opportunities_data
      reports = vacancies.filter_map(&:equal_opportunities_report).map(&:attributes)
      %i[age disability ethnicity gender orientation religion].index_with do |equal_type|
        merge_sum(filter_reports_by(reports, "#{equal_type}_"))
      end
    end

    def listing_data
      counts = vacancies.filter_map(&:vacancy_analytics).map(&:referrer_counts)
      merge_sum(counts)
    end

    def vacancies
      PublishedVacancy.in_organisation_ids(current_publisher.accessible_organisations(current_organisation).map(&:id))
    end

    def filter_reports_by(reports, value)
      # convert hash like {"age_thing" => 28, "age_other" => 24, "wibble" => 4, "age_other_descriptions"}
      #              into {"thing" => 28, "other" => 24}
      reports.map do |hash|
        hash.select { |k, _v| k.starts_with?(value) && k != "#{value}other_descriptions" }
                               .transform_keys { |k| k[value.length..] }
      end
    end

    def merge_sum(values)
      # use extended merge syntax to merge hashes by adding up the values
      values.reduce({}) do |hash, referrer_counts_hash|
        hash.merge(referrer_counts_hash) do |_key, v1, v2|
          v1 + v2
        end
      end
    end
  end
end
