module Jobseekers
  class EmailPreferencesForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :email_opt_out_reason, :email_opt_out_comment

    attribute :email_opt_out, :boolean

    validates :email_opt_out_reason, presence: true, if: -> { email_opt_out  }
    validates :email_opt_out_comment, presence: true, if: -> { email_opt_out && email_opt_out_reason == "other_close_account_reason" }
  end
end
