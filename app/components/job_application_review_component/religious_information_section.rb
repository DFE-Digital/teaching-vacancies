# frozen_string_literal: true

class JobApplicationReviewComponent::ReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application, allow_edit:)
    # don't include the details for if we don't follow a religion
    if job_application.following_religion
      super(job_application, forms: %w[FollowingReligionForm ReligionDetailsForm], name: :following_religion, allow_edit: allow_edit)
    else
      super(job_application, forms: %w[FollowingReligionForm], name: :following_religion, allow_edit: allow_edit)
    end
  end
end
