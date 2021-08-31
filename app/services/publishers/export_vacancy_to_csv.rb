require 'csv'

class Publishers::ExportVacancyToCsv
  attr_reader :vacancy

  def initialize(vacancy, number_of_unique_views)
    @vacancy = vacancy
    @number_of_unique_views = number_of_unique_views
  end

  def call
    columns = {
      "Organisation" => vacancy.organisation.name,
      "Job title" => vacancy.job_title,
      I18n.t("publishers.vacancies.statistics.show.views_by_jobseeker") => @number_of_unique_views,
      I18n.t("publishers.vacancies.statistics.show.saves_by_jobseeker") => vacancy.saved_jobs.count
    }

    if vacancy.can_receive_job_applications?
      columns.merge!({ I18n.t("publishers.vacancies.statistics.show.total_applications") => vacancy.job_applications.count,
                      I18n.t("publishers.vacancies.statistics.show.unread_applications") => vacancy.job_applications.submitted.count,
                      I18n.t("publishers.vacancies.statistics.show.shortlisted_applications") => vacancy.job_applications.shortlisted.count,
                      I18n.t("publishers.vacancies.statistics.show.rejected_applications") => vacancy.job_applications.unsuccessful.count,
                      I18n.t("publishers.vacancies.statistics.show.withdrawn_applications") => vacancy.job_applications.withdrawn.count
                    })
    end

    CSV.generate(headers: true) do |csv|
      csv << columns.keys
      csv << columns.values
    end
  end
end
