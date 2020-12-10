class VacancySort < RecordSort
  def default_column
    "expires_on"
  end

  def default_order
    "asc"
  end

  def valid_sort_columns
    %w[job_title
       readable_job_location
       expires_on
       publish_on
       created_at
       updated_at
       total_pageviews].freeze
  end
end
