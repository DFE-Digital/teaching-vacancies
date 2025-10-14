class Publishers::CandidateMessagesSort < RecordSort
  def options
    [unread_on_top_option, newest_on_top_option, oldest_on_top_option]
  end

  private

  def unread_on_top_option
    SortOption.new("unread_on_top", I18n.t("publishers.candidate_messages.index.sort_by.unread_on_top"))
  end

  def newest_on_top_option
    SortOption.new("newest_on_top", I18n.t("publishers.candidate_messages.index.sort_by.newest_on_top"))
  end

  def oldest_on_top_option
    SortOption.new("oldest_on_top", I18n.t("publishers.candidate_messages.index.sort_by.oldest_on_top"))
  end
end
