class CollegeSearchForm < OrganisationSearchForm
  def job_availability_options
    [["true", I18n.t("organisations.filters.college_job_availability.options.true")]]
  end

  def filters_list
    %i[
      job_availability
    ]
  end

  def total_filters
    [
      job_availability,
    ].compact.sum(&:count)
  end
end
