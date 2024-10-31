# frozen_string_literal: true

class JobApplicationReviewComponent::ReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application)
    super(job_application, forms: %w[FollowingReligionForm ReligionDetailsForm], name: :following_religion)
  end
end
