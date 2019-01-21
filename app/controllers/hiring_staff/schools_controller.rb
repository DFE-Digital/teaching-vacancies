class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @multiple_schools = session_has_multiple_schools?
    @school = SchoolPresenter.new(current_school)
    set_vacancies
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

  def set_vacancies
    case params[:type]
    when 'draft'
      @vacancy_type = :draft
      @vacancies = @school.vacancies.draft
    when 'pending'
      @vacancy_type = :pending
      @vacancies = @school.vacancies.pending
    when 'expired'
      @vacancy_type = :expired
      @vacancies = @school.vacancies.expired
    else
      @vacancy_type = :published
      @vacancies = @school.vacancies.live
    end
  end
end
