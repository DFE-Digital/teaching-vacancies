class VacancyAlertFilters < VacancyFilters
  AVAILABLE_FILTERS = superclass::AVAILABLE_FILTERS

  attr_reader(*AVAILABLE_FILTERS)

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    super(args)
  end

  def to_hash
    super()
  end
end
