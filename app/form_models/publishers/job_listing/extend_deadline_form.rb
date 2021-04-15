class Publishers::JobListing::ExtendDeadlineForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  EXPIRY_TIME_OPTIONS = %w[9:00 12:00 17:00 23:59].freeze

  attr_accessor :expires_on, :expiry_time, :starts_on, :starts_asap, :previous_deadline

  validates :expires_on, presence: true, date: true
  validates :starts_on, date: true, if: proc { starts_on.present? && starts_asap == "0" }
  validates :expiry_time, inclusion: { in: EXPIRY_TIME_OPTIONS }

  validate :expires_at_extended
  validate :expires_at_in_future
  validate :starts_on_in_future
  validate :starts_on_after_expires_at
  validate :starts_on_and_starts_asap_not_present

  def attributes_to_save
    {
      expires_on: expires_on,
      expires_at: expires_at,
      starts_on: (starts_on unless starts_asap == "true"),
      starts_asap: starts_asap,
    }
  end

  private

  def expires_at
    Time.zone.parse("#{expires_on[1]}-#{expires_on[2]}-#{expires_on[3]} #{expiry_time}")
  end

  def expires_at_extended
    return if expiry_time.nil? || expires_on.nil? || expires_at < Time.current

    errors.add(:expires_on, :not_extended) if expires_at <= previous_deadline
  rescue ArgumentError, TypeError
    nil
  end

  def expires_at_in_future
    return if expiry_time.nil? || expires_on.nil?

    errors.add(:expires_on, :in_past) if expires_at < Time.current
  rescue ArgumentError, TypeError
    nil
  end

  def starts_on_in_future
    return if starts_on.nil?

    errors.add(:starts_on, :in_past) if Date.new(starts_on[1], starts_on[2], starts_on[3]) < Date.current
  rescue ArgumentError, TypeError
    nil
  end

  def starts_on_after_expires_at
    return if starts_on.nil? || expires_on.nil? || Date.new(starts_on[1], starts_on[2], starts_on[3]) < Date.current

    errors.add(:starts_on, :before_deadline) if Date.new(starts_on[1], starts_on[2], starts_on[3]) < expires_at
  rescue ArgumentError, TypeError
    nil
  end

  def starts_on_and_starts_asap_not_present
    errors.add(:starts_on, :date_and_asap) if starts_on.present? && starts_asap == "true"
  end
end
