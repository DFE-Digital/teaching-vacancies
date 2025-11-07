class SelfDisclosure < ApplicationRecord
  belongs_to :self_disclosure_request

  has_encrypted :name, :previous_names, :address_line_1, :address_line_2, :city, :country, :postcode,
                :phone_number
  has_encrypted :date_of_birth, type: :date
  has_encrypted :has_unspent_convictions, :has_spent_convictions, :is_barred, :has_been_referred,
                :is_known_to_children_services, :has_been_dismissed, :has_been_disciplined,
                :has_been_disciplined_by_regulatory_body, :agreed_for_processing,
                :agreed_for_criminal_record, :agreed_for_organisation_update,
                :true_and_complete,
                :agreed_for_information_sharing, type: :boolean

  validates :self_disclosure_request_id, uniqueness: true

  def self.find_or_create_by_and_prefill!(job_application)
    find_or_create_by!(
      self_disclosure_request: job_application.self_disclosure_request,
    ) { |sd| sd.prefill(job_application) }
  end

  def prefill(job_application)
    job_fields = %w[previous_names city country postcode phone_number]
    attrs = job_application.attributes.slice(*job_fields)
    attrs["name"] = job_application.name
    attrs["address_line_1"] = job_application.street_address
    assign_attributes(attrs)
    save!
    itself
  end

  def mark_as_received
    job_application = self_disclosure_request.job_application
    vacancy = self_disclosure_request.job_application.vacancy
    registered_publisher_user = vacancy.organisation.publishers.find_by(email: vacancy.contact_email)

    self_disclosure_request.received!

    # cannot send a notification to a user that has not yet registered on our service so just send an email in that case.
    if registered_publisher_user
      Publishers::SelfDisclosureReceivedNotifier.with(record: self)
                                                .deliver
    else
      Publishers::CollectReferencesMailer.self_disclosure_received(job_application).deliver_later
    end
  end
end
