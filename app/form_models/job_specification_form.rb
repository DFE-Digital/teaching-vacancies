class JobSpecificationForm < VacancyForm
  attr_writer :working_pattern_ids
  # rubocop:disable Lint/AmbiguousOperator
  delegate *['starts_on_yyyy', 'starts_on_mm', 'starts_on_dd',
             'ends_on_dd', 'ends_on_mm', 'ends_on_yyyy',
             'expires_on'].map { |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten, to: :vacancy
  # rubocop:enable Lint/AmbiguousOperator

  include VacancyJobSpecificationValidations

  def initialize(params = {})
    if params[:working_pattern_ids].present?
      @working_pattern_ids = params[:working_pattern_ids]
      params[:working_patterns] = @working_pattern_ids.map { |id| WorkingPattern.find(id) }
    end
    super(params)
  end

  def working_pattern_ids
    @working_pattern_ids ||= vacancy.working_patterns.pluck(:id)
  end
end
