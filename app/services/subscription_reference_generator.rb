class SubscriptionReferenceGenerator
  attr_reader :search_criteria

  def initialize(search_criteria:)
    @search_criteria = search_criteria
  end

  def generate
    keyword = search_criteria['keyword']
    location = location_part

    return if keyword.blank? && location.blank?

    reference = keyword.present? ? "#{keyword.upcase_first} jobs" : 'Jobs'
    reference += " #{location}" if location.present?
    reference
  end

  private

  def location_part
    return unless location? || search_criteria['location_category'].present?

    search_criteria['location_category'].present? ?
      "in #{search_criteria['location_category']}" :
      "within #{search_criteria['radius']} miles of #{search_criteria['location'].strip}"
  end

  def location?
    ['location', 'radius'].all? { |key| search_criteria.key?(key) }
  end
end
