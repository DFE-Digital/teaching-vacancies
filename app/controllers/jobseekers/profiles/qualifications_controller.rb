class Jobseekers::Profiles::QualificationsController < Jobseekers::ProfilesController
  include Jobseekers::QualificationFormConcerns

  helper_method :jobseeker_profile, :qualification, :qualification_form_param_key

  before_action :set_form_and_category, except: %i[review confirm_destroy destroy select_category submit_category]

  def select_category
    @category = category_param
    @form = Jobseekers::Qualifications::CategoryForm.new
  end

  def submit_category
    @category = category_param
    @form = Jobseekers::Qualifications::CategoryForm.new(submit_category_params)

    if @form.valid?
      redirect_to new_jobseekers_profile_qualification_path(submit_category_params)
    else
      render :select_category, status: :unprocessable_entity
    end
  end

  def new; end

  def create
    if @form.valid?
      profile.qualifications.create(qualification_params)
      redirect_to review_jobseekers_profile_qualifications_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def review; end

  def update
    if @form.valid?
      qualification.update(qualification_params)
      redirect_to review_jobseekers_profile_qualifications_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    qualification.destroy
    redirect_to review_jobseekers_profile_qualifications_path, success: t(".success")
  end

  def confirm_destroy
    @category = qualification.category
    @form = Jobseekers::Qualifications::DeleteForm.new
  end

  private

  def form_attributes
    case action_name
    when "new"
      { category: @category }
    when "edit"
      qualification
        .slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, :qualification_results)
        .reject { |_, v| v.blank? && v != false }
    when "create", "update"
      qualification_params
    end
  end

  def submit_category_params
    key = ActiveModel::Naming.param_key(Jobseekers::Qualifications::CategoryForm)
    (params[key] || params).permit(:category)
  end

  def qualification_params
    case action_name
    when "new", "confirm_destroy"
      (params[qualification_form_param_key(@category)] || params).permit(:category)
    when "create", "edit", "update"
      params.require(qualification_form_param_key(@category))
            .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, qualification_results_attributes: %i[id subject grade])
    end
  end

  def set_form_and_category
    @category = action_name.in?(%w[edit update]) ? qualification.category : category_param
    @form = category_form_class(@category).new(form_attributes)
  end

  def category_param
    params.permit(:category)[:category]
  end

  def qualification
    @qualification ||= profile.qualifications.find(params[:id] || params[:qualification_id])
  end

  # def secondary?
  #   @category.in?(Qualification::SECONDARY_QUALIFICATIONS)
  # end
end
