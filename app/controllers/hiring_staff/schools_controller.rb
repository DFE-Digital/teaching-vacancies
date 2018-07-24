class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @multiple_schools = session.key?(:tva_permissions)
    @school = SchoolPresenter.new(current_school)
    @vacancies = @school.vacancies.active
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
end
