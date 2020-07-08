# Methods shared by controllers which can serve Step 1
# HiringStaff::Vacancies::JobSpecificationController is school-level users' Step 1
module FirstStepFormConcerns
  def set_up_form
    @form = form_class.new(form_params)
  end

  def save_form_params_on_vacancy_without_validation(vacancy)
    vacancy.status = :draft
    Auditor::Audit.new(vacancy, 'vacancy.create', current_session_id).log do
      vacancy.save(validate: false)
    end
    vacancy
  end

  def set_up_url
    @form_submission_url_method = @vacancy&.id.present? ? 'patch' : 'post'
    @form_submission_url = form_submission_path(@vacancy&.id)
  end
end
