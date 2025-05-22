class Jobseekers::JobApplication::Details::RefereeForm
  include ActiveModel::Model

  attr_accessor :name, :job_title, :organisation, :relationship, :email, :phone_number, :is_most_recent_employer

  validates :name, :job_title, :organisation, :relationship, :email, presence: true
  validates :email, email_address: true
  validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, allow_blank: true
  validates :is_most_recent_employer, inclusion: { in: [true, false, "true", "false"] }
end
