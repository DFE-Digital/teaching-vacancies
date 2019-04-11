class SubscriptionReferenceGenerator
  attr_reader :search_criteria

  def initialize(search_criteria:)
    @search_criteria = search_criteria
  end

  def generate
    job_type = job_type_part
    location = location_part

    return if job_type.blank? && location.blank?

    reference = job_type.present? ? "#{job_type.upcase_first} jobs" : 'Jobs'
    reference += " #{location}" if location.present?
    reference
  end

  private

  def job_type_part
    return unless job_type?

    parts = []

    parts.push(search_criteria['subject'].strip.split(/\s+/).join(' ')) if search_criteria.key?('subject')
    parts.push(search_criteria['job_title'].strip.split(/\s+/).join(' ')) if search_criteria.key?('job_title')

    parts.join(' ')
  end

  def job_type?
    ['subject', 'job_title'].any? { |key| search_criteria.key?(key) }
  end

  def location_part
    return unless location?

    "within #{search_criteria['radius']} miles of #{search_criteria['location'].strip}"
  end

  def location?
    ['location', 'radius'].all? { |key| search_criteria.key?(key) }
  end
end