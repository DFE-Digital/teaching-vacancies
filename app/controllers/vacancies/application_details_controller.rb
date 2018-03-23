class Vacancies::ApplicationDetailsController < Vacancies::ApplicationController
  before_action :school

  def new
    redirect_to job_specification_school_vacancy_path(school_id: @school.id) unless session_vacancy_id

    @application_details_form = ApplicationDetailsForm.new(session[:vacancy_attributes])
    @application_details_form.valid? if session[:current_step].eql?('step_3')
  end

  def create
    redirect_to job_specification_school_vacancy_path(school_id: @school.id) unless session_vacancy_id

    @application_details_form = ApplicationDetailsForm.new(application_details_form)
    store_vacancy_attributes(@application_details_form.vacancy.attributes.compact!)

    if @application_details_form.valid?
      vacancy = update_vacancy(application_details_form)

      session[:current_step] = :review
      redirect_to school_vacancy_review_path(school_id: @school.id, vacancy_id: vacancy.id)
    else
      session[:current_step] = :step_3
      redirect_to application_details_school_vacancy_path(school_id: @school.id)
    end
  end

  private

  def application_details_form
    params.require(:application_details_form).permit(:contact_email,
                                                     :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                                                     :publish_on_dd, :publish_on_mm, :publish_on_yyyy)
  end
end
