class HiringStaff::Vacancies::ApplicationDetailsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(application_details_form_params, @vacancy)
  end

  def show
    @application_details_form = ApplicationDetailsForm.new(@vacancy.attributes)
  end

  def update
    @application_details_form = ApplicationDetailsForm.new(application_details_form_params)

    if @application_details_form.valid?
      update_vacancy(application_details_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end

    render :show
  end

private

  def application_details_form_params
    params.require(:application_details_form)
          .permit(:state, :application_link, :contact_email, :contact_number, :school_visits, :how_to_apply)
          .merge(completed_step: current_step)
  end

  def next_step
    organisation_job_job_summary_path(@vacancy.id)
  end
end
