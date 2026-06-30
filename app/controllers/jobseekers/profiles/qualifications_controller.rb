class Jobseekers::Profiles::QualificationsController < Jobseekers::ProfilesController
  include Jobseekers::QualificationFormConcerns

  helper_method :jobseeker_profile, :qualification, :qualification_form_param_key

  before_action :set_category, only: %i[new create edit update]

  def select_category
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

  def new
    @form = category_form_class(@category).new({ category: @category })
  end

  def create
    @form = category_form_class(@category).new(qualification_params)

    if @form.valid?
      @profile.qualifications.create(qualification_params)
      redirect_to review_jobseekers_profile_qualifications_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    form_attributes = qualification
            .slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, :qualification_results)
            .reject { |_, v| v.blank? && v != false }

    @form = category_form_class(@category).new(form_attributes)
  end

  def review; end

  def update
    @form = category_form_class(@category).new(qualification_params)

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

  def submit_category_params
    key = ActiveModel::Naming.param_key(Jobseekers::Qualifications::CategoryForm)
    (params[key] || params).permit(:category)
  end

  def qualification_params
    params.expect(qualification_form_param_key(@category) => [:category,
                                                              :finished_studying,
                                                              :finished_studying_details,
                                                              :grade,
                                                              :institution,
                                                              :name,
                                                              :subject,
                                                              :year,
                                                              :awarding_body,
                                                              { qualification_results_attributes: [%i[id subject grade awarding_body]] }])
  end

  def set_category
    @category = action_name.in?(%w[edit update]) ? qualification.category : category_param
  end

  def category_param
    params.permit(:category)[:category]
  end

  def qualification
    @qualification ||= @profile.qualifications.find(params[:id] || params[:qualification_id])
  end
end
