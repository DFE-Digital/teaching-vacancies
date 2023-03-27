require_dependency "multistep/controller"

class Publishers::InvitationsController < Publishers::BaseController
  include ::Multistep::Controller

  multistep_form Publishers::InviteForm, key: :invite
  escape_path { publishers_jobseeker_profile_path(@form.jobseeker_profile_id) }

  def index
    @profile = JobseekerProfile.find(params[:id])
    @invitations = InvitationToApply.where(
      jobseeker_id: @profile.jobseeker_id,
      vacancy_id: current_organisation.all_vacancies.select(:id),
    )
  end

  def start
    @form = self.class.multistep_form.new(
      jobseeker_profile_id: params[:id],
      organisation_id: current_organisation.id,
      publisher_id: current_publisher.id,
    )
    store_form!

    redirect_to action: :edit, step: all_steps.first
  end

  def complete
    @form.complete!
    flash[:success] = "Invited to apply for a job"
    redirect_to escape_path
  end
end
