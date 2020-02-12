class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create]

  def index
    @documents_form = DocumentsForm.new(session[:vacancy_attributes] || documents_form_params)
  end

  def create
    @documents_form = DocumentsForm.new(documents_form_params)

    @documents_form.errors.add(:base, 'One of the files contains a virus!')
    @documents_form.errors.add(:documents, 'The selected file(s) could not be uploaded!')
    # store_vacancy_attributes(documents_form_params)
    # vacancy = update_vacancy(documents_form_params)

    render :index
  end

  private

  def documents_form_params
    params.require(:documents_form).permit(documents: [])
  end
end
