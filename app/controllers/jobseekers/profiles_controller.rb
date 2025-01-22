class Jobseekers::ProfilesController < Jobseekers::BaseController
  include Jobseekers::QualificationFormConcerns

  before_action :check_activable!, only: %i[confirm_toggle toggle]

  helper_method :qualification_form_param_key

  SECTIONS = [
    {
      title: "Personal details",
      display_summary: -> { profile.personal_details&.completed_steps.present? },
      key: "personal_details",
      link_text: "Add personal details",
      page_path: -> { personal_details_jobseekers_profile_path },
    },
    {
      title: "Job preferences",
      display_summary: -> { profile.job_preferences&.completed_steps.present? },
      key: "job_preferences",
      link_text: "Add job preferences",
      page_path: -> { jobseekers_job_preferences_path },
    },
    {
      title: "Professional Status",
      display_summary: -> { profile.qualified_teacher_status.present? },
      key: "qualified_teacher_status",
      link_text: "Add qualified teacher status",
      page_path: -> { edit_jobseekers_profile_qualified_teacher_status_path },
    },
    {
      title: "Qualifications",
      display_summary: -> { profile.qualifications.present? },
      key: "qualifications",
      link_text: "Add qualifications",
      page_path: -> { select_category_jobseekers_profile_qualifications_path },
    },
    {
      title: "Training and continuing professional development (CPD)",
      display_summary: -> { profile.training_and_cpds.present? },
      key: "training_and_cpds",
      link_text: "Add training",
      page_path: -> { new_jobseekers_profile_training_and_cpd_path },
    },
    {
      title: "Professional Body Memberships",
      display_summary: -> { profile.professional_body_memberships.present? },
      key: "professional_body_memberships",
      link_text: "Add professional body membership",
      page_path: -> { new_jobseekers_profile_professional_body_membership_path },
    },
    {
      title: "Work history",
      display_summary: -> { profile.employments.any? },
      key: "employments",
      link_text: "Add roles",
      page_path: -> { new_jobseekers_profile_work_history_path },
    },
    {
      title: "About you",
      display_summary: -> { profile.about_you.present? },
      key: "about_you",
      condition: -> { profile.about_you.present? },
      link_text: "Add details about you",
      page_path: -> { edit_jobseekers_profile_about_you_path },
      partial: "jobseekers/profiles/about_you/summary",
    },
    {
      title: I18n.t("jobseekers.profiles.show.hide_profile"),
      display_summary: -> { !profile.requested_hidden_profile.nil? },
      key: "hide_profile",
      link_text: I18n.t("jobseekers.profiles.show.set_up_profile_visibility"),
      page_path: -> { jobseekers_profile_hide_profile_path },
    },
  ].map(&:freeze).freeze

  def show
    @sections = SECTIONS
    @off_on = (profile.active? ? "off" : "on")
  end

  def confirm_toggle
    @off_on = (profile.active? ? "off" : "on")
  end

  def toggle
    profile.update!(active: !profile.active?)
    redirect_to jobseekers_profile_path, success: t("jobseekers.profiles.show.profile_turned_#{profile.active? ? 'on' : 'off'}")
  end

  private

  def check_activable!
    return if profile.active? || profile.activable?

    flash[:important] = t("jobseekers.profiles.toggle.not_ready")
    redirect_to action: :show
  end

  def profile
    @profile ||= JobseekerProfile.prepare(jobseeker: current_jobseeker) do
      flash.now[:success] = t("jobseekers.profiles.show.imported")
    end
  end
  helper_method :profile
end
