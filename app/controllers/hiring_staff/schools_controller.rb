class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @multiple_schools = session_has_multiple_schools?
    @school = SchoolPresenter.new(current_school)
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)
    @vacancy_presenter = SchoolVacanciesPresenter.new(@school, @sort, params[:type])
    @awaiting_feedback_count = @school.vacancies.awaiting_feedback.count
  end

  def edit
    @school = current_school
    return if params[:description].nil?

    @school.description = params[:description].presence
    @school.valid?
  end

  def update
    school = current_school
    school.description = params[:school][:description]

    if school.valid?
      Auditor::Audit.new(school, 'school.update', current_session_id).log do
        school.save
      end
      redirect_to school_path
    else
      redirect_to edit_school_path(description: school.description)
    end
  end

  private

  def session_has_multiple_schools?
    session.key?(:multiple_schools) && session[:multiple_schools] == true
  end

  def sort_column
    params[:type] == 'draft' ? (params[:sort_column] || 'created_at') : params[:sort_column]
  end

  def sort_order
    params[:type] == 'draft' ? (params[:sort_order] || 'desc') : params[:sort_order]
  end
end
