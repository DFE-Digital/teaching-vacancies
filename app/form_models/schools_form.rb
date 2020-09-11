class SchoolsForm < VacancyForm
  attr_accessor :organisation_id, :organisation_ids

  validate :organisation_id_present_one_school
  validate :more_than_one_school_present_multiple_schools

  def initialize(params = {})
    @organisation_id = params[:organisation_id]
    @organisation_ids = params[:organisation_ids]
    super
  end

private

  def organisation_id_present_one_school
    errors.add(:organisation_id, I18n.t('schools_errors.organisation_id.blank')) if
      vacancy&.job_location == 'at_one_school' && organisation_id.blank?
  end

  def more_than_one_school_present_multiple_schools
    return errors.add(:organisation_ids, I18n.t('schools_errors.organisation_ids.blank')) if
      vacancy&.job_location == 'at_multiple_schools' && organisation_ids.blank?

    errors.add(:organisation_ids, I18n.t('schools_errors.organisation_ids.invalid')) if
      vacancy&.job_location == 'at_multiple_schools' && organisation_ids.count < 2
  end
end
