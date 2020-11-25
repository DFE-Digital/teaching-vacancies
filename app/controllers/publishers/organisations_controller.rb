class Publishers::OrganisationsController < Publishers::BaseController
  before_action :redirect_to_user_preferences

  def show
    @multiple_organisations = session_has_multiple_organisations?
    @organisation = current_organisation
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)
    @filters = Publishers::VacancyFilter.new(current_publisher, current_school_group).to_h
    @managed_organisations_form = ManagedOrganisationsForm.new(@filters)
    @selected_type = params[:type]
    @awaiting_feedback_count = @organisation.vacancies.awaiting_feedback.count

    render_draft_saved_message if params[:from_review]

    flash.now[:notice] = I18n.t("messages.jobs.feedback.awaiting", count: @awaiting_feedback_count) if
      @awaiting_feedback_count.positive?
  end

private

  def redirect_to_user_preferences
    if current_organisation.is_a?(SchoolGroup) && current_publisher_preferences.nil?
      redirect_to organisation_managed_organisations_path
    end
  end

  def session_has_multiple_organisations?
    session[:multiple_organisations] == true
  end

  def sort_column
    params[:type] == "draft" ? (params[:sort_column] || "created_at") : params[:sort_column]
  end

  def sort_order
    params[:type] == "draft" ? (params[:sort_order] || "desc") : params[:sort_order]
  end

  def render_draft_saved_message
    vacancy = current_organisation.all_vacancies.find(params[:from_review])
    flash.now[:success] = I18n.t("messages.jobs.draft_saved_html", job_title: vacancy.job_title)
  end
end
