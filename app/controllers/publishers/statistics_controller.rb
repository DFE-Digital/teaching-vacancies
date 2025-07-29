module Publishers
  class StatisticsController < BaseController
    before_action :set_bar_chart

    def index
      counts = vacancies.filter_map(&:vacancy_analytics).map(&:referrer_counts)
      @referrer_counts = merge_sum(counts)
    end

    def equal_opportunities
      reports = vacancies.filter_map(&:equal_opportunities_report).map(&:attributes)
      @age_counts = merge_sum(filter_reports_by(reports, "age_"))
      @disability_counts = merge_sum(filter_reports_by(reports, "disability_"))
      @ethnicity_counts = merge_sum(filter_reports_by(reports, "ethnicity_"))
      @gender_counts = merge_sum(filter_reports_by(reports, "gender_"))
      @orientation_counts = merge_sum(filter_reports_by(reports, "orientation_"))
      @religion_counts = merge_sum(filter_reports_by(reports, "religion_"))
    end

    private

    def set_bar_chart
      @bar_chart = params[:view] != "table"
    end

    def vacancies
      current_publisher.vacancies.active_in_current_academic_year
    end

    # convert hash like {"age_thing" => 28, "age_other" => 24, "wibble" => 43}
    #              into {"thing" => 28, "other" => 24}
    def filter_reports_by(reports, value)
      reports.map do |hash|
        hash.select { |k, _v| k.starts_with?(value) && k != "#{value}other_descriptions" }
                               .transform_keys { |k| k[value.length..] }
      end
    end

    def merge_sum(values)
      values.reduce({}) do |hash, referrer_counts_hash|
        hash.merge(referrer_counts_hash) do |_key, v1, v2|
          v1 + v2
        end
      end
    end
  end
end
