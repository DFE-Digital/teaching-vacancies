class HiringStaff::Vacancies::SupportingDocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy

  def show
    @supporting_documents_form = SupportingDocumentsForm.new(@vacancy.attributes)
  end

  def update
    @supporting_documents_form = SupportingDocumentsForm.new(supporting_documents_form_params)

    if @supporting_documents_form.valid?
      store_vacancy_attributes(@supporting_documents_form.vacancy.attributes)
      update_vacancy(supporting_documents_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  private

  def supporting_documents_form_params
    (params[:supporting_documents_form] || params)
      .permit(:supporting_documents)
      .merge(completed_step: current_step)
  end

  def next_step
    @supporting_documents_form.supporting_documents == 'yes' ?
      school_job_documents_path(@vacancy.id) : school_job_application_details_path(@vacancy.id)
  end

  def redirect_to_next_step_if_save_and_continue
    if session[:current_step].eql?(:review) && @supporting_documents_form.supporting_documents == 'yes'
      redirect_to school_job_documents_path(@vacancy.id)
    elsif params[:commit] == I18n.t('buttons.save_and_continue')
      redirect_to_next_step(@vacancy)
    elsif params[:commit] == I18n.t('buttons.update_job')
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    end
  end
end
