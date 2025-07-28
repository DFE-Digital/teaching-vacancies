module StatisticsHelper
  def sort_referrer_counts(referrer_counts)
    referrer_counts.map { |k, v| [k, v] }.sort_by { |_k, v| -v }.to_h
  end

  def sort_age_stats(referrer_counts)
    age_sort_order = %w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say]

    referrer_counts.sort_by { |k, _v| age_sort_order.index(k) }.to_h
  end
end
