require "csv"

class Publishers::ExportVacancyToCsv
  class << self
    def call(vacancy, job_application_counts)
      columns = base_columns vacancy
      columns.merge!(job_application_columns(job_application_counts)) if vacancy.can_receive_job_applications?

      CSV.generate(headers: true) do |csv|
        csv << columns.keys
        csv << columns.values
      end
    end

    private

    def base_columns(vacancy)
      {
        "Organisation" => vacancy.organisation_name,
        I18n.t("jobs.job_title") => vacancy.job_title,
      }
    end

    def job_application_columns(job_application_counts)
      { I18n.t("publishers.vacancies.statistics.show.total_applications") => job_application_counts.sum }
        .merge(job_application_counts.map.with_index { |count, index| [I18n.t(".applications.#{index}", scope: "publishers.vacancies.statistics.show"), count] }.to_h)
    end
  end
end
