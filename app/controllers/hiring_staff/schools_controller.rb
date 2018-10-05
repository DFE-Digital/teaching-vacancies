class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @multiple_schools = session_has_multiple_schools?
    @school = SchoolPresenter.new(current_school)
    @vacancies = @school.vacancies.active

    @get_information_count = @vacancies.any? ? retrieve_get_information_count(@vacancies) : 0
    @weekly_pageviews = @vacancies.pluck(:weekly_pageviews).compact.inject(:+)
    @total_pageviews = @vacancies.pluck(:total_pageviews).compact.inject(:+)
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

  def retrieve_get_information_count(vacancies)
    vacancy_ids = vacancies.pluck(:id).join("','")
    PublicActivity::Activity.where("trackable_id in ('#{vacancy_ids}')")
                            .where(key: 'vacancy.get_more_information').count
  end
end
