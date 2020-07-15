class HiringStaff::Organisations::ManagedOrganisationsController < HiringStaff::BaseController
  before_action :verify_school_group

  def show
    @managed_organisations_form = ManagedOrganisationsForm.new(current_user, current_organisation)
  end

  def update
    @managed_organisations_form = ManagedOrganisationsForm.new(
      current_user, current_organisation, managed_organisations_form_params
    )

    if @managed_organisations_form.valid?
      @managed_organisations_form.save
      redirect_to organisation_path
    else
      render :show
    end
  end

  private

  def update_managed_organisations
    if params[:commit] == I18n.t('buttons.skip_this_step')
      params[:managed_organisations_form][:managed_organisations] = ['all']
    elsif params[:managed_organisations_form][:managed_organisations].blank?
      params[:managed_organisations_form][:managed_organisations] = []
    end
  end

  def managed_organisations_form_params
    update_managed_organisations
    strip_empty_checkboxes(:managed_organisations_form, [:managed_organisations, :managed_school_urns])
    params.require(:managed_organisations_form).permit(managed_organisations: [], managed_school_urns: [])
  end

  def verify_school_group
    redirect_to organisation_path, danger: 'You are not allowed' unless current_organisation.is_a?(SchoolGroup)
  end
end
