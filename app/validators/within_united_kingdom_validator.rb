class WithinUnitedKingdomValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless Geocoding.new(value.strip).uk_coordinates?
      record.errors.add(attribute, I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
    end
  end
end
