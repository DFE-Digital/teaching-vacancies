class OrganisationVacancy < ApplicationRecord
  belongs_to :organisation
  belongs_to :vacancy

  after_commit :set_postcode_from_mean_geolocation

  def set_postcode_from_mean_geolocation
    vacancy.set_postcode_from_mean_geolocation!
  end
end
