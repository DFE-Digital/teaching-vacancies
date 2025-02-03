# frozen_string_literal: true

class JobApplicationReviewComponent::NonCatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application, allow_edit:, name:)
    super(job_application, forms: %w[NonCatholicForm], name: name, allow_edit: allow_edit)
  end
end
