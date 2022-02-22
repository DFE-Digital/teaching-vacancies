class Publishers::OrganisationsController < Publishers::BaseController
  before_action :show_publisher_preferences
  before_action :redirect_to_new_features_page, only: %i[show]

  helper_method :vacancy_statistics_form

  def show
    @selected_type = params[:type] || :published
    @publisher_preference = PublisherPreference.find_or_create_by(publisher: current_publisher, organisation: current_organisation)
    @sort = Publishers::VacancySort.new(current_organisation, @selected_type).update(sort_by: params[:sort_by])
    render_draft_saved_message if params[:from_review]
  end

  private

  def show_publisher_preferences
    return unless current_organisation.local_authority?
    return if PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    redirect_to new_publishers_publisher_preference_path
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

  def redirect_to_new_features_page
    redirect_to new_features_path if session[:visited_new_features_page].nil? && show_new_features_page?
  end

  def show_new_features_page?
    return false if current_organisation.local_authority?

    return false if publisher_has_used_feature?

    current_publisher.dismissed_new_features_page_at.blank?
  end

  def publisher_has_used_feature?
    current_publisher.vacancies.where(enable_job_applications: true).any? do |vacancy|
      vacancy.main_job_role == "education_support"
    end
  end

  def statistics_params
    params.require(:publishers_vacancy_statistics_form).permit(:listed_elsewhere, :hired_status)
  end
end
