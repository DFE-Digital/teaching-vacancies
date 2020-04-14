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

    parts.push(strip_split_join(search_criteria['keyword'])) if search_criteria.key?('keyword')
    parts.push(strip_split_join(search_criteria['subject'])) if search_criteria.key?('subject')
    parts.push(strip_split_join(search_criteria['job_title'])) if search_criteria.key?('job_title')

    parts.join(' ')
  end

  def strip_split_join(field)
    field.strip.split(/\s+/).join(' ')
  end

  def job_type?
    ['keyword', 'subject', 'job_title'].any? { |key| search_criteria.key?(key) }
  end

  def location_part
    return unless location?

    "within #{search_criteria['radius']} miles of #{search_criteria['location'].strip}"
  end

  def location?
    ['location', 'radius'].all? { |key| search_criteria.key?(key) }
  end
end
