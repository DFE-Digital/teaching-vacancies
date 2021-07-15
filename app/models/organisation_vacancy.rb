class OrganisationVacancy < ApplicationRecord
  belongs_to :organisation
  belongs_to :vacancy

  after_create :set_mean_geolocation
  after_destroy :set_mean_geolocation

  def set_mean_geolocation
    vacancy.set_mean_geolocation!
  end
end
