class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @school = SchoolPresenter.new(current_school)
    @vacancies = @school.vacancies.active
  end

  def edit
    @school = School.find(params[:id])

    return if params[:description].nil?

    @school.description = params[:description].presence
    @school.valid?
  end

  def update
    school = School.find(params[:id])
    school.description = params[:school][:description]

    if school.valid?
      Auditor::Audit.new(school, 'school.update', current_session_id).log do
        school.save
      end
      redirect_to school_path(school)
    else
      redirect_to edit_school_path(school, description: school.description)
    end
  end
end
