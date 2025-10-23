class DocumentPreviewService
  Document = Data.define(:filename, :data)

  PREVIEWS = {
    # rubocop:disable Layout/HashAlignment
    blank:           ["job_application", :blank_job_application_sample],
    plain:           ["job_application", :job_application_sample],
    religious:       ["job_application", :religious_job_application_sample],
    catholic:        ["job_application", :catholic_job_application_sample],
    self_disclosure: ["self_disclosure", :self_disclosure_sample],
    job_reference:   ["job_reference", :job_reference_sample],
    # rubocop:enable Layout/HashAlignment
  }.freeze

  PDF_GENERATORS = {
    job_application: ->(data) { JobApplicationPdfGenerator.new(data).generate.render },
    self_disclosure: ->(data) { SelfDisclosurePdfGenerator.new(data).generate.render },
    job_reference: ->(data) { ReferencePdfGenerator.new(data).generate.render },
  }.with_indifferent_access

  def self.call(...)
    new(...).document
  end

  def initialize(id, vacancy)
    @vacancy = vacancy
    @sample_name, @sample_method = PREVIEWS.fetch(id.to_sym)
  end

  def document
    Document[filename, pdf_data]
  end

  private

  def data
    send(@sample_method, @vacancy)
  end

  def pdf_data
    @pdf_data ||= PDF_GENERATORS.fetch(@sample_name).call(data)
  end

  def filename
    "#{@sample_name}_#{pdf_data.object_id}.pdf"
  end

  def blank_job_application_sample(vacancy)
    job_application = JobApplicationSample.build(
      vacancy,
      referees: 2,
      employments: Array.new(5, :job),
      training_and_cpds: 3,
      qualifications: { gcse: 5, a_level: 5, undergraduate: 2, postgraduate: 2, other: 0 },
      professional_body_memberships: 2,
    )

    BlankJobApplicationPdf.new(job_application)
  end

  def job_application_sample(vacancy)
    job_application = JobApplicationSample.build(vacancy)
    JobApplicationPdf.new(job_application)
  end

  def religious_job_application_sample(vacancy)
    vacancy.religion_type = "other_religion"
    job_application = JobApplicationSample.build(vacancy)
    JobApplicationPdf.new(job_application)
  end

  def catholic_job_application_sample(vacancy)
    vacancy.religion_type = "catholic"
    job_application = JobApplicationSample.build(vacancy)
    JobApplicationPdf.new(job_application)
  end

  def job_reference_sample(vacancy)
    job_application = JobApplicationSample.build(vacancy)
    referee = job_application.referees.first
    referee.assign_attributes(
      reference_request: ReferenceRequest.new(job_reference: build_job_reference),
    )
    RefereePresenter.new(referee)
  end

  def self_disclosure_sample(vacancy)
    job_application = JobApplicationSample.build(vacancy)
    job_application.assign_attributes(
      self_disclosure_request: SelfDisclosureRequest.new(self_disclosure: build_self_disclosure),
    )
    SelfDisclosurePresenter.new(job_application)
  end

  def build_job_reference # rubocop: disable Metrics/MethodLength
    JobReference.new(
      complete: true,
      can_give_reference: true,
      name: "Doretta Conroy",
      job_title: "Headmaster",
      phone_number: "01234 5654345",
      email: "gerald_zboncak@contoso.com",
      organisation: "Sample school",
      how_do_you_know_the_candidate: "Officiis est perspiciatis. Est aliquam fuga. Accusamus harum aut.",
      reason_for_leaving: "no reason",
      would_reemploy_current_reason: "wonderful",
      would_reemploy_any_reason: "fantastic",
      currently_employed: false,
      would_reemploy_current: true,
      would_reemploy_any: true,
      employment_start_date: 5.years.ago,
      employment_end_date: 1.day.ago,
      under_investigation: false,
      warnings: false,
      allegations: false,
      not_fit_to_practice: false,
      able_to_undertake_role: true,
      under_investigation_details: "Omnis et ullam adipisci.",
      warning_details: "Vel quibusdam consequuntur laboriosam.",
      unable_to_undertake_reason: "Odit et quos reiciendis.",
      punctuality: "outstanding",
      working_relationships: "outstanding",
      customer_care: "outstanding",
      adapt_to_change: "outstanding",
      deal_with_conflict: "outstanding",
      prioritise_workload: "outstanding",
      team_working: "good",
      communication: "outstanding",
      problem_solving: "outstanding",
      general_attitude: "outstanding",
      technical_competence: "poor",
      leadership: "outstanding",
    )
  end

  def build_self_disclosure # rubocop: disable Metrics/MethodLength
    SelfDisclosure.new(
      name: "Doretta Conroy",
      previous_names: "Neville Torp LLD",
      address_line_1: "682 Keeling Divide",
      address_line_2: "88039 Bartell Manor",
      city: "East Chris",
      postcode: "UC5 7NB",
      country: "Country",
      phone_number: "01234 567890",
      date_of_birth: 20.years.ago,
      has_unspent_convictions: false,
      has_spent_convictions: false,
      is_barred: false,
      has_been_referred: false,
      is_known_to_children_services: false,
      has_been_dismissed: false,
      has_been_disciplined: false,
      has_been_disciplined_by_regulatory_body: false,
      agreed_for_processing: true,
      agreed_for_criminal_record: true,
      agreed_for_organisation_update: true,
      agreed_for_information_sharing: true,
      true_and_complete: true,
    )
  end
end
