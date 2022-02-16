class Publishers::Vacancies::CopyController < Publishers::Vacancies::BaseController
  before_action :set_up_copy_form, only: %i[create]

  def new
    vacancy.status = :draft
    reset_date_fields if vacancy.publish_on&.past?
    attributes = vacancy.slice(:job_title, :expires_at, :publish_on, :starts_on, :starts_asap)
    @copy_form = Publishers::JobListing::CopyVacancyForm.new(attributes, vacancy)
  end

  def create
    if @copy_form.valid?
      new_vacancy = CopyVacancy.new(vacancy).call
      new_vacancy.assign_attributes(@copy_form.params_to_save)
      new_vacancy.refresh_slug
      new_vacancy.save
      update_google_index(new_vacancy) if new_vacancy.listed?
      redirect_to organisation_job_review_path(new_vacancy.id)
    else
      render :new
    end
  end

  private

  def copy_form_params
    params.require(:publishers_job_listing_copy_vacancy_form)
          .permit(:job_title, :publish_on, :publish_on_day, :expires_at, :expiry_time, :starts_on, :starts_asap)
  end

  def set_up_copy_form
    vacancy.status = :draft
    reset_date_fields
    @copy_form = Publishers::JobListing::CopyVacancyForm.new(copy_form_params, vacancy)
  end

  def reset_date_fields
    vacancy.expires_at = nil
    vacancy.starts_asap = nil
    vacancy.starts_on = nil
    vacancy.publish_on = nil
  end
end
