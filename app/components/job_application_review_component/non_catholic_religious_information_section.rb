# frozen_string_literal: true

class JobApplicationReviewComponent::NonCatholicReligiousInformationSection < JobApplicationReviewComponent::Section
  def initialize(job_application, allow_edit:, name:)
    # only include the details form if we follow a religion
    forms = if job_application.following_religion
              %w[SchoolEthosForm FollowingReligionForm NonCatholicReligionDetailsForm]
            else
              %w[SchoolEthosForm FollowingReligionForm]
            end
    super(job_application, forms: forms, name: name, allow_edit: allow_edit)
  end
end
