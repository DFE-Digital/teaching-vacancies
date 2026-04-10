class JobApplicationReviewComponent::CatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application, name:)
    super(job_application, forms: %w[CatholicForm], name: name)
  end
end
