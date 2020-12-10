class SavedJobSort < RecordSort
  def default_column
    "created_at"
  end

  def default_order
    "desc"
  end

  def valid_sort_columns
    %w[created_at vacancies.expires_at].freeze
  end
end
