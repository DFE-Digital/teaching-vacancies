class OrganisationVacancy < ApplicationRecord
  belongs_to :organisation
  belongs_to :vacancy

  after_save do
    vacancy.set_mean_geolocation!
  end
end
