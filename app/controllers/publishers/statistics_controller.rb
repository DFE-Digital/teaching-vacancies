module Publishers
  class StatisticsController < BaseController
    before_action :set_bar_chart

    include StatisticsHelper

    def index
      respond_to do |format|
        format.html do
          @referrer_counts = listing_data(vacancies.active_in_current_academic_year)
        end
        format.csv do
          data = sort_referrer_counts(listing_data(vacancies)).to_h
          csv_data = CSV.generate(headers: false) do |csv|
            csv << data.keys
            csv << data.values
          end

          send_data csv_data, filename: "statistics.csv"
        end
      end
    end

    def equal_opportunities
      respond_to do |format|
        format.html do
          reports = vacancies.active_in_current_academic_year.filter_map(&:equal_opportunities_report).map(&:attributes)
          @age_counts = merge_sum(filter_reports_by(reports, "age_"))
          @disability_counts = merge_sum(filter_reports_by(reports, "disability_"))
          @ethnicity_counts = merge_sum(filter_reports_by(reports, "ethnicity_"))
          @gender_counts = merge_sum(filter_reports_by(reports, "gender_"))
          @orientation_counts = merge_sum(filter_reports_by(reports, "orientation_"))
          @religion_counts = merge_sum(filter_reports_by(reports, "religion_"))
        end
        format.csv do
          reports = vacancies.filter_map(&:equal_opportunities_report).map(&:attributes)
          age_counts = sort_age_stats(merge_sum(filter_reports_by(reports, "age_"))).to_h
          disability_counts = sort_referrer_counts(merge_sum(filter_reports_by(reports, "disability_"))).to_h
          ethnicity_counts = sort_referrer_counts(merge_sum(filter_reports_by(reports, "ethnicity_"))).to_h
          gender_counts = sort_referrer_counts(merge_sum(filter_reports_by(reports, "gender_"))).to_h
          orientation_counts = sort_referrer_counts(merge_sum(filter_reports_by(reports, "orientation_"))).to_h
          religion_counts = sort_referrer_counts(merge_sum(filter_reports_by(reports, "religion_"))).to_h

          csv_data = CSV.generate(headers: false) do |csv|
            csv << age_counts.keys
            csv << age_counts.values
            csv << disability_counts.keys
            csv << disability_counts.values
            csv << ethnicity_counts.keys
            csv << ethnicity_counts.values
            csv << gender_counts.keys
            csv << gender_counts.values
            csv << orientation_counts.keys
            csv << orientation_counts.values
            csv << religion_counts.keys
            csv << religion_counts.values
          end

          send_data csv_data, filename: "equal_oppuntunities.csv"
        end
      end
    end

    private

    def listing_data(vacancies)
      counts = vacancies.filter_map(&:vacancy_analytics).map(&:referrer_counts)
      merge_sum(counts)
    end

    def set_bar_chart
      @bar_chart = params[:view] != "table"
    end

    def vacancies
      PublishedVacancy.in_organisation_ids(current_publisher.accessible_organisations(current_organisation))
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
