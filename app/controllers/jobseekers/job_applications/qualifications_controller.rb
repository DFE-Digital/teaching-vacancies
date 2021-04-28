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
      shared_attributes.merge(varied_attributes).merge(qualification_params.to_h)
    when "create", "update", "submit_category"
      qualification_params
    end
  end

  def shared_attributes
    qualifications.first.slice(:category, :finished_studying, :finished_studying_details, :institution, :name, :year)
  end

  def varied_attributes
    (qualifications + built_qualifications).each_with_object({}).with_index { |(qualification, hash), index|
      hash.merge!(qualification.slice(:subject, :grade).transform_keys { |key| key + (index + 1).to_s })
    }
  end

  def built_qualifications
    @built_qualifications ||=
      valid_varied_param_key_rows&.map do |param_key_row|
        param_keys_for_single_record = shared_param_keys.concat(param_key_row)
        job_application.qualifications.find_or_initialize_by(
          qualification_params.permit(param_keys_for_single_record).transform_keys { |attribute_name|
            attribute_name.gsub(param_key_digit(attribute_name), "")
          })
      end || []
  end

  def valid_varied_param_key_rows
    group_param_keys_into_rows(varied_param_keys)&.select do |param_key_row|
      qualification_params.permit(param_key_row).values.any?(&:present?) ||
        param_key_digit(param_key_row.last) == "1" # permit blank row 1 because subject is optional for some forms
      end
  end

  def group_param_keys_into_rows(param_keys)
    param_keys&.group_by { |key| param_key_digit(key) }&.values
  end

  def varied_param_keys
    form_params&.keys&.select { |key| param_key_digit(key).present? }
  end

  def shared_param_keys
    %i[category finished_studying finished_studying_details institution name year]
  end

  def qualification_params
    case action_name
    when "new", "select_category", "submit_category"
      (form_params || params).permit(:category)
    when "create", "edit", "update"
      form_params&.permit(shared_param_keys.concat(varied_param_keys))
    end
  end

  def form_params
    params[form_param_key(category)]
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

  alias form_param_key qualification_form_param_key
end
