class Publishers::PublisherPreferencesController < Publishers::BaseController
  before_action :strip_empty_publisher_preference_checkboxes, only: %i[create update]

  def new
    @publisher_preference = PublisherPreference.new
  end

  def create
    @publisher_preference = PublisherPreference.new(publisher: current_publisher, organisation: current_organisation)

    if publisher_preference_params[:school_ids].any?
      @publisher_preference.update schools: Organisation.find(publisher_preference_params[:school_ids])
      redirect_to publisher_root_path
    else
      @publisher_preference.errors.add(:school_ids_fieldset, t(".form.missing_schools_error"))
      render :new
    end
  end

  def edit
    @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)
  end

  def update
    @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    if publisher_preference_params[:school_ids]&.none?
      @publisher_preference.errors.add(:school_ids_fieldset, t(".form.missing_schools_error"))
      return render :edit
    elsif publisher_preference_params[:school_ids]&.any?
      @publisher_preference.update schools: Organisation.find(publisher_preference_params[:school_ids])
    end
    redirect_to organisation_jobs_path
  end

  private

  def publisher_preference_params
    params.expect(publisher_preference: [{ school_ids: [] }])
  end

  def strip_empty_publisher_preference_checkboxes
    strip_empty_checkboxes(%i[school_ids], :publisher_preference)
  end
end
