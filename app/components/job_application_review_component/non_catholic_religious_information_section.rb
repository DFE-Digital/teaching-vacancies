# frozen_string_literal: true

class JobApplicationReviewComponent::NonCatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application, name:)
    super(job_application, forms: %w[NonCatholicForm], name: name)
  end
end
