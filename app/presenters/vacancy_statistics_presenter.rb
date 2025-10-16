# frozen_string_literal: true

class VacancyStatisticsPresenter
  EQUAL_OPPORTUNITIES_LABELS = %w[
    age_group
    age_group_count
    disability_status
    disability_status_count
    ethnicity
    ethnicity_count
    gender_identity
    gender_identity_count
    sexual_orientation
    sexual_orientation_count
    faith_group
    faith_group_count
  ].freeze

  def initialize(vacancies)
    @vacancies = vacancies
  end

  def equal_opportunities_data
    reports = @vacancies.filter_map(&:equal_opportunities_report).map(&:attributes)
    %i[age disability ethnicity gender orientation religion].index_with do |equal_type|
      value = merge_sum(filter_reports_by(reports, "#{equal_type}_"))

      if equal_type == :age
        sort_age_stats(value)
      else
        sort_referrer_counts(value)
      end
    end
  end

  def equal_opportunities_csv
    rows = equal_opportunities_data.flat_map { |_, stats| [stats.keys, stats.values] }
    rows.each_with_index.map { |row, i| [EQUAL_OPPORTUNITIES_LABELS[i], *row] }
  end

  def referrer_counts
    counts = @vacancies.filter_map(&:vacancy_analytics).map(&:referrer_counts)
    raw_counts = merge_sum(counts)
    sort_referrer_counts(raw_counts).transform_keys(&:humanize)
  end

  private

  def sort_age_stats(referrer_counts)
    age_sort_order = %w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say]

    referrer_counts.sort_by { |k, _v| age_sort_order.index(k) }.to_h
  end

  # sort referrers with high value first
  def sort_referrer_counts(referrer_counts)
    referrer_counts.sort_by { |_k, v| -v }.to_h
  end

  def filter_reports_by(reports, value)
    # convert hash like {"age_thing" => 28, "age_other" => 24, "wibble" => 4, "age_other_descriptions"}
    #              into {"thing" => 28, "other" => 24}
    reports.map do |hash|
      hash.select { |k, _v| k.starts_with?(value) && k != "#{value}other_descriptions" }
          .transform_keys { |k| k[value.length..] }
    end
  end

  def merge_sum(values)
    # use extended merge syntax to merge hashes by adding up the values
    values.reduce({}) do |hash, referrer_counts_hash|
      hash.merge(referrer_counts_hash) do |_key, v1, v2|
        v1 + v2
      end
    end
  end
end
