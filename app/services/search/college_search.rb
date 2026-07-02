module Search
  class CollegeSearch < OrganisationSearch
    def clear_filters_params
      active_criteria.merge({ job_availability: [] })
    end
  end
end
