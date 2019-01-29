class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @multiple_schools = session_has_multiple_schools?
    @school = SchoolPresenter.new(current_school)
    @vacancy_presenter = SchoolVacanciesPresenter.new(@school, params[:type])
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
end
