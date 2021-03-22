class Publishers::Vacancies::StatisticsController < Publishers::Vacancies::BaseController
  before_action :set_vacancy

  def update
    if Publishers::VacancyStatisticsForm.new(statistics_params).valid?
      @vacancy.listed_elsewhere = statistics_params[:listed_elsewhere]
      @vacancy.hired_status = statistics_params[:hired_status]

      # An expired vacancy can be invalid, if validations have been added since it was published.
      @vacancy.save(validate: false)

      redirect_to jobs_with_type_organisation_path(type: :awaiting_feedback),
                  success: t(".success", job_title: @vacancy.job_title)
    else
      redirect_to jobs_with_type_organisation_path(type: :awaiting_feedback, params: {
        invalid_form_job_id: @vacancy.id,
        publishers_vacancy_statistics_form: statistics_params,
      })
    end
  end

  private

  def statistics_params
    params.require(:publishers_vacancy_statistics_form).permit(:listed_elsewhere, :hired_status)
  end
end
