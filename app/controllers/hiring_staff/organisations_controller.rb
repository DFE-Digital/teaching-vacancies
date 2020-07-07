class HiringStaff::OrganisationsController < HiringStaff::BaseController
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
