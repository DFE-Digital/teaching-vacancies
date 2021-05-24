class Publishers::JobListing::ImportantDatesForm < Publishers::JobListing::VacancyForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  EXPIRY_TIME_OPTIONS = %w[9:00 12:00 17:00 23:59].freeze

  delegate :published?, to: :vacancy

  attr_accessor :expiry_time, :starts_asap
  attr_reader :expires_at, :publish_on, :starts_on

  validates :publish_on, date: { on_or_after: :today }, unless: proc { published? }
  validates :expires_at, date: { on_or_after: :now, after: :publish_on }
  validates :expiry_time, inclusion: { in: EXPIRY_TIME_OPTIONS }
  validates :starts_on, date: { on_or_after: :today, after: :expires_at }, allow_blank: true,
                        if: proc { starts_asap == "0" }
  validate :starts_on_and_starts_asap_not_present

  def initialize(params, vacancy)
    @expiry_time = params[:expiry_time] || vacancy.expires_at&.strftime("%k:%M")&.strip

    super(params, vacancy)
  end

  def disable_editing_publish_on?
    published? && (vacancy.reload.publish_on.past? || vacancy.reload.publish_on.today?)
  end

  def params_to_save
    {
      publish_on: publish_on,
      expires_at: expires_at,
      starts_on: (starts_on unless starts_asap == "true"),
      starts_asap: starts_asap,
      completed_step: completed_step,
    }.delete_if { |k, v| k == :completed_step && v.blank? }
  end

  def expires_at=(value)
    expires_on = date_from_multiparameter_hash(value)
    @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
  end

  def publish_on=(value)
    @publish_on = date_from_multiparameter_hash(value)
  end

  def starts_on=(value)
    @starts_on = date_from_multiparameter_hash(value)
  end

  private

  def starts_on_and_starts_asap_not_present
    errors.add(:starts_on, :date_and_asap) if starts_on.present? && starts_asap == "true"
  end
end
