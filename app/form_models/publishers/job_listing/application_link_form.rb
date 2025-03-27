class Publishers::JobListing::ApplicationLinkForm < Publishers::JobListing::VacancyForm
  validates :application_link, presence: true, url: { allow_blank: true }

  def self.fields
    %i[application_link]
  end
  attr_accessor(*fields)

  def next_step
    :application_form
  end
end
