class HiringStaff::Vacancies::ApplicationDetailsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    @application_details_form = ApplicationDetailsForm.new(session[:vacancy_attributes])
    @application_details_form.valid? if %i[step_3 review].include?(session[:current_step])
  end

  def create
    @application_details_form = ApplicationDetailsForm.new(application_details_form)
    store_vacancy_attributes(@application_details_form.vacancy.attributes.compact!)

    if @application_details_form.valid?
      vacancy = update_vacancy(application_details_form)
      redirect_to next_step(vacancy)
    else
      session[:current_step] = :step_3 unless session[:current_step].eql?(:review)
      redirect_to application_details_school_job_path(school_id: @school.id)
    end
  end

  def edit
    vacancy = school.vacancies.published.find(vacancy_id)

    @application_details_form = ApplicationDetailsForm.new(vacancy.attributes)
    @application_details_form.valid?
  end

  def update
    vacancy = school.vacancies.published.find(vacancy_id)
    @application_details_form = ApplicationDetailsForm.new(application_details_form)
    @application_details_form.id = vacancy.id

    if @application_details_form.valid?
      update_vacancy(application_details_form, vacancy)
      redirect_to edit_school_job_path(school, vacancy.id), notice: I18n.t('messages.vacancies.updated')
    else
      render 'edit'
    end
  end

  private

  def application_details_form
    params.require(:application_details_form).permit(:application_link, :contact_email,
                                                     :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                                                     :publish_on_dd, :publish_on_mm, :publish_on_yyyy)
  end

  def next_step(vacancy)
    review_path(vacancy)
  end
end
