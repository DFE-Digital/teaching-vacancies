module Publishers
  class JobApplication::RejectionEmailsForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :job_applications

    validates_length_of :job_applications, minimum: 1
  end
end
