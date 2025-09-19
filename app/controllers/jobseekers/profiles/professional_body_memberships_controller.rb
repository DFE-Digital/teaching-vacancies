class Jobseekers::Profiles::ProfessionalBodyMembershipsController < Jobseekers::ProfilesController
  helper_method :jobseeker_profile, :professional_body_membership

  def new
    @form = Jobseekers::ProfessionalBodyMembershipForm.new
  end

  def edit
    @form = Jobseekers::ProfessionalBodyMembershipForm.new(professional_body_membership.slice(:name, :membership_type, :membership_number, :year_membership_obtained, :exam_taken))
  end

  def create
    @form = Jobseekers::ProfessionalBodyMembershipForm.new(professional_body_memberships_form_params)

    if @form.valid?
      @profile.professional_body_memberships.create!(professional_body_memberships_form_params)
      redirect_to review_jobseekers_profile_professional_body_memberships_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::ProfessionalBodyMembershipForm.new(professional_body_memberships_form_params)
    if @form.valid?
      professional_body_membership.update!(professional_body_memberships_form_params)
      redirect_to review_jobseekers_profile_professional_body_memberships_path
    else
      render :edit
    end
  end

  def confirm_destroy
    @form = Jobseekers::ProfessionalBodyMembershipForm.new
  end

  def destroy
    professional_body_membership.destroy!
    redirect_to review_jobseekers_profile_professional_body_memberships_path, success: t(".success")
  end

  def professional_body_memberships_form_params
    params.expect(jobseekers_professional_body_membership_form: %i[name membership_type membership_number year_membership_obtained exam_taken])
  end

  def professional_body_membership
    @professional_body_membership ||= @profile.professional_body_memberships.find(params[:id] || params[:professional_body_membership_id])
  end
end
