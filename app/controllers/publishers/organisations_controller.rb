class Publishers::OrganisationsController < Publishers::BaseController
  before_action :show_publisher_preferences

  helper_method :vacancy_statistics_form

  def show
    @selected_type = params[:type]
    @publisher_preference = PublisherPreference.find_or_create_by(publisher: current_publisher, organisation: current_organisation)
    @sort = Publishers::VacancySort.new(current_organisation, @selected_type).update(column: params[:sort_column])
    @sort_form = SortForm.new(@sort.column)
    @awaiting_feedback_count = current_organisation.vacancies.awaiting_feedback.count
    flash.now[:notice] = t(".awaiting", count: @awaiting_feedback_count) if @awaiting_feedback_count.positive?
    render_draft_saved_message if params[:from_review]
  end

  private

  def show_publisher_preferences
    return unless current_organisation.local_authority_code?
    return if PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    redirect_to new_publisher_preference_path
  end

  def render_draft_saved_message
    vacancy = current_organisation.all_vacancies.find(params[:from_review])
    flash.now[:success] = t("messages.jobs.draft_saved_html", job_title: vacancy.job_title)
  end

  def vacancy_statistics_form(vacancy)
    if vacancy.id == params[:invalid_form_job_id]
      # Trigger validations to add errors to form
      Publishers::VacancyStatisticsForm.new(statistics_params).tap(&:valid?)
    else
      @vacancy_statistics_form ||= Publishers::VacancyStatisticsForm.new
    end
  end

  def statistics_params
    params.require(:publishers_vacancy_statistics_form).permit(:listed_elsewhere, :hired_status)
  end
end
