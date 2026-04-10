# frozen_string_literal: true

class JobApplicationReviewComponent::NonCatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application)
    super(job_application, :non_catholic, forms: %w[NonCatholicForm])
  end
end
