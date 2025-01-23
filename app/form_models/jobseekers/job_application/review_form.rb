module Jobseekers
  module JobApplication
    class ReviewForm < PreSubmitForm
      attr_accessor :confirm_data_accurate, :confirm_data_usage

      validates_acceptance_of :confirm_data_accurate, :confirm_data_usage,
                              acceptance: true,
                              if: :all_steps_completed?

      include ActiveModel::Attributes

      attribute :update_profile, :boolean
    end
  end
end
