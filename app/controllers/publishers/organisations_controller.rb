class Publishers::OrganisationsController < Publishers::BaseController
  include Sortable

  before_action :redirect_to_user_preferences

  def show
    @multiple_organisations = session_has_multiple_organisations?
    @organisation = current_organisation
    @sort = VacancySort.new.update(column: organisations_sort_column, order: organisations_sort_order)
    @filters = Publishers::VacancyFilter.new(current_publisher, current_school_group).to_h
    @managed_organisations_form = ManagedOrganisationsForm.new(@filters)
    @vacancy_sort_form = VacancySortForm.new(organisations_sort_column)
    @selected_type = params[:type]
    @awaiting_feedback_count = @organisation.vacancies.awaiting_feedback.count

    render_draft_saved_message if params[:from_review]

    flash.now[:notice] = t(".awaiting", count: @awaiting_feedback_count) if @awaiting_feedback_count.positive?
  end

private

  def redirect_to_user_preferences
    return unless current_organisation.is_a?(SchoolGroup) && current_publisher_preferences.nil?

    redirect_to organisation_managed_organisations_path
  end

  def session_has_multiple_organisations?
    session[:publisher_multiple_organisations] == true
  end

  def render_draft_saved_message
    vacancy = current_organisation.all_vacancies.find(params[:from_review])
    flash.now[:success] = t("messages.jobs.draft_saved_html", job_title: vacancy.job_title)
  end
end
