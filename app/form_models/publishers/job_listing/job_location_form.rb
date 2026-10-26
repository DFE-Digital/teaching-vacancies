class Publishers::JobListing::JobLocationForm < Publishers::JobListing::JobListingForm
  attr_accessor :organisation_ids, :phases

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*fields))
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def field_list
      %i[organisations]
    end
  end

  def self.fields
    %i[organisation_ids phases]
  end

  def params_to_save
    { organisations: Organisation.find(organisation_ids) }
  end
end
