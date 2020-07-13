class HiringStaff::OrganisationsController < HiringStaff::BaseController
  before_action :redirect_to_user_preferences, except: :placeholder

  def placeholder; end

  def show
    @multiple_organisations = session_has_multiple_organisations?
    @organisation = organisation_presenter
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)
    @vacancies_presenter = OrganisationVacanciesPresenter.new(@organisation, @sort, params[:type])
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

  def organisation_presenter
    return SchoolPresenter.new(current_organisation) if current_organisation.is_a?(School)
    # TODO: Implement SchoolGroupPresenter
  end

  def redirect_to_user_preferences
    if current_organisation.is_a?(SchoolGroup) && current_user_preferences.nil?
      redirect_to organisation_user_preference_path
    # TODO: Remove when organisations controller can tolerate SchoolGroup objects
    elsif current_organisation.is_a?(SchoolGroup)
      redirect_to school_group_temporary_path
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
    vacancy = current_school.vacancies.find(params[:from_review])
    flash.now[:success] = I18n.t('messages.jobs.draft_saved_html', job_title: vacancy&.job_title)
  end
end
