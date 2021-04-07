class Jobseekers::JobApplications::QualificationsController < Jobseekers::BaseController
  include Jobseekers::QualificationsHelper
  include QualificationFormConcerns

  helper_method :back_path, :category, :form, :job_application, :qualifications, :secondary?

  def submit_category
    if form.valid?
      redirect_to new_jobseekers_job_application_qualification_path(qualification_params)
    else
      render :select_category
    end
  end

  def create
    if form.valid?
      built_qualifications.each(&:save)
      update_in_progress_steps!(:qualifications)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      (qualifications - built_qualifications).each(&:destroy)
      built_qualifications.each(&:save)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    count = qualifications.destroy_all.count
    redirect_to back_path, success: t(".success", count: count)
  end

  private

  def form
    @form ||= form_class(category).new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      { category: category }
    when "select_category"
      {}
    when "edit"
      attributes = qualifications.first.slice(:category, :finished_studying, :finished_studying_details, :institution, :name, :year)
      (qualifications + built_qualifications).map.with_index { |qualification, index|
        attributes.merge!(qualification.slice(:subject, :grade).transform_keys { |key| key + (index + 1).to_s })
      }.uniq
      attributes.merge(qualification_params.to_h)
    when "create", "update", "submit_category"
      qualification_params
    end
  end

  def built_qualifications
    @built_qualifications ||=
      repeatable_param_keys&.group_by { |key| param_key_digit(key) }&.values&.select { |keys|
        param_key_digit(keys.last) == "1" ||
          qualification_params.permit(keys).values.any?(&:present?)
      }&.map do |subject_and_grade_param_keys|
        job_application.qualifications.find_or_initialize_by(
          qualification_params.permit(unique_param_keys.concat(subject_and_grade_param_keys))
                              .transform_keys { |key| key.split(/\d+/).first },
        )
      end || []
  end

  def qualification_params
    case action_name
    when "new", "select_category", "submit_category"
      (params[form_param_key(category)] || params).permit(:category)
    when "create", "edit", "update"
      params[form_param_key(category)]&.permit(unique_param_keys.concat(repeatable_param_keys))
    end
  end

  def unique_param_keys
    %i[category finished_studying finished_studying_details institution name year]
  end

  def repeatable_param_keys
    params[form_param_key(category)]&.keys&.select { |key| param_key_digit(key).present? }
  end

  def category
    @category ||= if action_name.in?(%w[edit update])
                    qualifications.first.category
                  else
                    params.permit(:category)[:category]
                  end
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :qualifications)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def qualifications
    @qualifications ||= job_application.qualifications.where(id: params[:ids])
  end

  def secondary?
    category.in?(Qualification::SECONDARY_QUALIFICATIONS)
  end
end
