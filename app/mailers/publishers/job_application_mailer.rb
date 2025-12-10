module Publishers
  class JobApplicationMailer < BaseMailer
    include VacanciesHelper

    def applications_received(publisher, publisher_vacancies)
      @publisher_vacancies = publisher_vacancies

      job_applications_count = @publisher_vacancies.sum { |vacancy| vacancy.job_applications.submitted_yesterday.count }

      template = ERB.new(Rails.root.join("app/views/publishers/job_application_mailer/applications_received.text.erb").read)

      @vacancies = @publisher_vacancies.index_with { |v| { location: vacancy_job_location(v), link: organisation_job_job_applications_url(v.id) } }

      template_mail("ea1ec36c-a1d4-4d75-b6ba-b4cbbdfb5c83",
                    to: publisher.email,
                    personalisation: {
                      job_applications_count: job_applications_count,
                      vacancies_list: template.result(binding),
                      home_page_link: root_url,
                    })
    end

    private

    def dfe_analytics_custom_data
      { vacancies_job_applications: vacancies_job_applications }
    end

    def vacancies_job_applications
      @publisher_vacancies.each_with_object({}) do |vacancy, hash|
        hash[vacancy.id] = vacancy.job_applications.submitted_yesterday.pluck(:id)
      end
    end
  end
end
