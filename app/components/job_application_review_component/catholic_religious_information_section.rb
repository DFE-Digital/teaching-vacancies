class JobApplicationReviewComponent::CatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application)
    super(job_application, :catholic, forms: %w[CatholicForm])
  end
end
