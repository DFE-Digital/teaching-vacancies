class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :status, :string
  attribute :offered_at, :date_or_hash
  attribute :declined_at, :date_or_hash

  attr_accessor :job_applications, :origin, :vacancy

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, on: :update_tag
  validates :offered_at, date: {}, allow_nil: true
  validates :declined_at, date: {}, allow_nil: true

  def job_application_ids
    return [] if job_applications.blank?

    job_applications.pluck(:id)
  end

  def available_statuses
    case origin
    when "shortlisted" then %i[unsuccessful interviewing offered]
    when "interviewing" then %i[unsuccessful offered]
    else
      %i[reviewed unsuccessful shortlisted interviewing offered]
    end
  end

  def tabs
    %w[submitted unsuccessful shortlisted interviewing offered].map do |tab_name|
      count = candidates[tab_name].count
      count += candidates["declined"].count if tab_name == "offered"
      [tab_name, count]
    end
  end

  def candidates
    return @candidates if @candidates.present?

    @candidates = JobApplication.statuses.transform_values do |status_idx|
      vacancy.job_applications.where(status: status_idx)
    end

    @candidates["submitted"] = vacancy.job_applications.where(status: %i[submitted reviewed])
    @candidates["unsuccessful"] = vacancy.job_applications.where(status: %i[unsuccessful withdrawn])

    @candidates
  end

  def attributes
    hsh = super
    return hsh.except("declined_at") if status == "offered"
    return hsh.except("offered_at") if status == "declined"

    hsh.except("declined_at", "offered_at")
  end
end
