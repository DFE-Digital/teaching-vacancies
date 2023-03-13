require_dependency 'multistep/controller'

class Publishers::InvitationsController < Publishers::BaseController
  include ::Multistep::Controller

  multistep_form Publishers::InviteForm, key: :invite
  escape_path { root_path } # TODO: { jobseeker_profile_path }

  def start
    @form = self.class.multistep_form.new(
      jobseeker_id: params[:id],
      organisation_id: current_organisation.id,
      publisher_id: current_publisher.id,
    )
    store_form!

    redirect_to action: :edit, step: all_steps.first
  end
end
