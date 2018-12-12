class HiringStaff::Vacancies::RepublishController < HiringStaff::Vacancies::ApplicationController
  def new
    @republish_form = RepublishForm.new(vacancy_attributes)
    @school = school
    @republish_form.valid? if params[:source]&.eql?('republish')
  end

  def create
    @republish_form = RepublishForm.new(republish_form)
    @republish_form.id = vacancy_id
    if @republish_form.valid?
      update_vacancy(republish_form, vacancy)
      redirect_to school_job_publish_path(vacancy.id, source: 'republish')
    else
      @school = school
      render :new, source: 'republish'
    end
  end

  private

  def republish_form
    params.require(:republish_form).permit(:starts_on_dd, :starts_on_mm,
                                           :starts_on_yyyy, :ends_on_dd,
                                           :ends_on_mm, :ends_on_yyyy,
                                           :expires_on_dd, :expires_on_mm,
                                           :expires_on_yyyy, :publish_on_dd,
                                           :publish_on_mm, :publish_on_yyyy)
  end

  def vacancy_attributes
    vacancy.attributes
  end

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end

  def vacancy
    school.vacancies.published.find(vacancy_id)
  end
end
