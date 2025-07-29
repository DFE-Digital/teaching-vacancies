class VacancyTabsPresenter
  TABS_DEFINITION = {
    submitted: %w[submitted reviewed],
    unsuccessful: %w[unsuccessful withdrawn],
    shortlisted: %w[shortlisted],
    interviewing: %w[interviewing],
    offered: %w[offered declined],
  }.stringify_keys

  class << self
    def tabs_data(vacancy)
      TABS_DEFINITION.transform_values do |statuses|
        ordering = statuses.map { :"#{it}_at" }.index_with { :desc }
        vacancy.job_applications.where(status: statuses).order(ordering)
      end
    end

    def tab_for(job_application_status)
      reverse_lookup[job_application_status]
    end

    private

    def reverse_lookup
      return @reverse_lookup if @reverse_lookup.present?

      @reverse_lookup = TABS_DEFINITION.transform_values(&:itself).invert.merge(
        TABS_DEFINITION.flat_map { |k, v| v.map { |val| [val, k] } }.to_h,
      )
    end
  end
end
