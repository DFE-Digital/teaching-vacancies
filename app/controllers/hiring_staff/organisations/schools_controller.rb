class HiringStaff::Organisations::SchoolsController < HiringStaff::BaseController
  before_action :set_redirect_path, only: %i[edit update]
  before_action :set_organisation, only: %i[edit update]

  def index; end

  def edit; end

  def update
    if @organisation.update(description: description)
      redirect_to_organisation_or_organisation_schools_path
    else
      render :edit
    end
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  def set_redirect_path
    @redirect_path = current_organisation.is_a?(School) ? organisation_path : organisation_schools_path
  end

  def description
    (params[:school_group] || params[:school])[:description]
  end

  def redirect_to_organisation_or_organisation_schools_path
    redirect_to @redirect_path,
                success: I18n.t('messages.organisation.description_updated_html', organisation: @organisation.name)
  end
end
