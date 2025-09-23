class SelfDisclosurePresenter
  PERSONAL_DETAILS = %i[name previous_names address_line_1 address_line_2 city country postcode phone_number date_of_birth].freeze

  SECTIONS = {
    criminal: %i[has_unspent_convictions has_spent_convictions is_barred has_been_referred],
    conduct: %i[is_known_to_children_services has_been_dismissed has_been_disciplined has_been_disciplined_by_regulatory_body],
    confirmation: %i[agreed_for_processing agreed_for_criminal_record agreed_for_organisation_update agreed_for_information_sharing],
  }.freeze

  Section = Data.define(:title, :fields)

  def initialize(job_application)
    @job_application = job_application
    @request = job_application.self_disclosure_request
    @model = job_application.self_disclosure
  end

  attr_reader :model, :job_application, :request

  def events
    request.versions.reverse_each.map do |version|
      next unless version.changeset.key?("status")

      label = case version.changeset["status"].last
              in "manually_completed"
                t(".event.manually_completed")
              in "manual"
                t(".event.managed_outside_tv")
              in "received"
                t(".event.completed")
              in "sent"
                t(".event.requested")
              end
      actor = version.actor&.papertrail_display_name || "Teaching Vacancies"
      timestamp = version.created_at.to_fs
      [label, "#{actor} - #{timestamp}"]
    end
  end

  def personal_details
    Enumerator.new do |y|
      PERSONAL_DETAILS.each { y << row(it) }
    end
  end

  def sections
    Enumerator.new do |y|
      SECTIONS.each do |title, fields|
        next if title == :confirmation

        y << Section[t(title), fields.map { row(it) }]
      end

      y << Section[t(:confirmation), SECTIONS[:confirmation].map { [nil, t(it)] }]
    end
  end

  def applicant_name
    job_application.name
  end

  def header_text
    t(".self_disclosure_form")
  end

  def footer_text
    "#{header_text} - #{applicant_name}"
  end

  private

  def t(key)
    I18n.t(key, scope: "jobseekers.job_applications.self_disclosure.review.completed")
  end

  def format(value)
    case value
    in Date
      value.to_fs
    in TrueClass | FalseClass
      t(".#{value}")
    in NilClass
      t(".n_a")
    else
      value
    end
  end

  def row(field)
    [t(field), format(model[field])]
  end
end
