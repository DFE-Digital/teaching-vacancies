class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :status, :string
  attr_accessor :job_applications, :origin

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, on: :update_tag

  def job_application_ids
    return [] if job_applications.blank?

    job_applications.pluck(:id)
  end

  def update_job_application_statuses
    case origin
    when "shortlisted" then %i[unsuccessful interviewing offered]
    when "interviewing" then %i[unsuccessful offered]
    else
      %i[reviewed unsuccessful shortlisted interviewing offered]
    end
  end

  def self.fields
    [:origin, :status, { job_applications: [] }]
  end
end
