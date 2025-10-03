module Publishers
  class JobApplication::RejectionEmailForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :subject
    attribute :content
    attribute :contact_email
    attribute :from

    attribute :include_school_logo, :boolean
    attribute :email_copy, :boolean
  end
end
