class HiringStaff::OrganisationsController < HiringStaff::BaseController
  before_action :redirect_to_user_preferences

  def show
    @multiple_organisations = session_has_multiple_organisations?
    @organisation = current_organisation
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)
    @filters = HiringStaff::VacancyFilter.new(current_user, current_school_group).to_h
    @selected_type = params[:type]
    @awaiting_feedback_count = @organisation.vacancies.awaiting_feedback.count

    render_draft_saved_message if params[:from_review]

    flash.now[:notice] = I18n.t('messages.jobs.feedback.awaiting', count: @awaiting_feedback_count) if
      @awaiting_feedback_count.positive?
  end

  def edit
    @organisation = current_organisation
    return if params[:description].nil?

    @organisation.description = params[:description].presence
    @organisation.valid?
  end

  def update
    @organisation = current_organisation
    @organisation.description = params[:school][:description]

    if @organisation.valid?
      Auditor::Audit.new(@organisation, 'school.update', current_session_id).log do
        @organisation.save
      end
      return redirect_to organisation_path
    end

    render :edit
  end

  private

  def redirect_to_user_preferences
    if current_organisation.is_a?(SchoolGroup) && current_user_preferences.nil?
      redirect_to organisation_managed_organisations_path
    end
  end

  def current_user_preferences
    UserPreference.find_by(
      user_id: current_user.id, school_group_id: current_organisation.id
    ) if current_organisation.is_a?(SchoolGroup)
  end

  def session_has_multiple_organisations?
    session[:multiple_organisations] == true
  end

  def sort_column
    params[:type] == 'draft' ? (params[:sort_column] || 'created_at') : params[:sort_column]
  end

  def sort_order
    params[:type] == 'draft' ? (params[:sort_order] || 'desc') : params[:sort_order]
  end

  def render_draft_saved_message
    vacancy = current_organisation.vacancies.find(params[:from_review])
    flash.now[:success] = I18n.t('messages.jobs.draft_saved_html', job_title: vacancy&.job_title)
  end
end
