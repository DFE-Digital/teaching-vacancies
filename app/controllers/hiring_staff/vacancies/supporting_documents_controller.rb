class HiringStaff::Vacancies::SupportingDocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(supporting_documents_form_params, @vacancy)
  end

  def show
    @supporting_documents_form = SupportingDocumentsForm.new(@vacancy.attributes)
  end

  def update
    @supporting_documents_form = SupportingDocumentsForm.new(supporting_documents_form_params)

    if @supporting_documents_form.valid?
      store_vacancy_attributes(@supporting_documents_form.vacancy.attributes)
      update_vacancy(supporting_documents_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_documents_or_next_step
    end

    render :show
  end

private

  def supporting_documents_form_params
    (params[:supporting_documents_form] || params)
      .permit(:state, :supporting_documents)
      .merge(completed_step: current_step)
  end

  def next_step
    @supporting_documents_form.supporting_documents == 'yes' ? organisation_job_documents_path(@vacancy.id) : organisation_job_application_details_path(@vacancy.id)
  end

  def redirect_to_documents_or_next_step
    if session[:current_step].eql?(:review) && @supporting_documents_form.supporting_documents == 'yes'
      redirect_to organisation_job_documents_path(@vacancy.id)
    else
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end
  end
end
