class VacancyAlertFilters < VacancyFilters
  AVAILABLE_FILTERS = %i[keyword].concat(superclass::AVAILABLE_FILTERS).freeze

  attr_reader(*AVAILABLE_FILTERS)

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    @keyword = args[:keyword]

    super(args)
  end

  def to_hash
    super().merge(keyword: keyword)
  end
end
