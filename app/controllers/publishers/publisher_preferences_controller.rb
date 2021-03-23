class Publishers::PublisherPreferencesController < Publishers::BaseController
  def new
    @publisher_preference = PublisherPreference.new
  end

  def create
    publisher_preference = PublisherPreference.create(publisher: current_publisher, organisation: current_organisation)
    set_local_authority_publisher_schools(publisher_preference)
    redirect_to organisation_path
  end

  def edit
    @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)
  end

  def update
    publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    if params[:publisher_preference][:school_ids]
      set_local_authority_publisher_schools(publisher_preference)
    elsif params[:publisher_preference][:organisation_ids]
      set_organisation_publisher_preferences(publisher_preference)
    end
    redirect_to jobs_with_type_organisation_path(params[:publisher_preference][:jobs_type])
  end

  private

  def set_local_authority_publisher_schools(publisher_preference)
    strip_empty_checkboxes(%i[school_ids], :publisher_preference)
    publisher_preference.local_authority_publisher_schools.delete_all
    params[:publisher_preference][:school_ids].each do |school_id|
      publisher_preference.local_authority_publisher_schools.create(school_id: school_id)
    end
  end

  def set_organisation_publisher_preferences(publisher_preference)
    strip_empty_checkboxes(%i[organisation_ids], :publisher_preference)
    publisher_preference.organisation_publisher_preferences.delete_all
    params[:publisher_preference][:organisation_ids].each do |organisation_id|
      publisher_preference.organisation_publisher_preferences.create(organisation_id: organisation_id)
    end
  end
end
