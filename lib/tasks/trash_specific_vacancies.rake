namespace :vacancies do
  desc "Trash vacancies with specific external references"
  task trash_specific: :environment do
    detailed_school_types_to_trash = [
      "Further education",
      "Other independent school",
      "Online provider",
      "British schools overseas",
      "Institution funded by other government department",
      "Miscellaneous",
      "Offshore schools",
      "Service children’s education",
      "Special post 16 institution",
      "Other independent special school",
      "Higher education institutions",
      "Welsh establishment"
    ].freeze

    Vacancy.joins(:organisation_vacancies)
           .joins("JOIN organisations ON organisation_vacancies.organisation_id = organisations.id")
           .where(organisations: { detailed_school_type: detailed_school_types_to_trash })
           .find_each do |vacancy|
      vacancy.update!(status: "trashed")
    end
  end
end
