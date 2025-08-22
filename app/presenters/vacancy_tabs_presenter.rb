class VacancyTabsPresenter
  TABS_DEFINITION = {
    submitted: %w[submitted reviewed],
    unsuccessful: %w[unsuccessful withdrawn],
    shortlisted: %w[shortlisted],
    interviewing: %w[interviewing unsuccessful_interview],
    offered: %w[offered declined],
  }.stringify_keys

  class << self
    def job_applications_to_tabs(job_applications_hash)
      TABS_DEFINITION.transform_values do |status_list|
        status_list.index_with { |status| job_applications_hash.fetch(status, []) }
      end
    end

    def tab_for(job_application_status)
      reverse_lookup[job_application_status]
    end

    private

    def reverse_lookup
      @reverse_lookup ||= TABS_DEFINITION.invert.flat_map { |keys, v| keys.map { |k| [k, v] } }.to_h
    end
  end
end
