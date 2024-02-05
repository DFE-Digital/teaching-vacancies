class Jobseekers::JobApplications::EmploymentGapFinder
  def initialize(record)
    @record = record
    @today = Time.zone.today
  end

  def significant_gaps(threshold: 3.months)
    record.employments.each_with_object({}) do |employment, gaps|
      next if employment.current_role?
      next if gap_to_today_is_less_than_threshold?(employment, threshold)
      next if overlapping_employment?(employment)
      next if next_employment_started_within_threshold?(employment, threshold)

      gaps[employment] = {
        started_on: employment.ended_on + 1.day,
        ended_on: gap_end_date(employment) || today,
      }
    end
  end

  private

  attr_reader :record, :today

  def gap_to_today_is_less_than_threshold?(employment, threshold)
    employment.ended_on + threshold >= today
  end

  def overlapping_employment?(employment)
    record.employments.any? do |other|
      next if employment == other
      next if other.started_on.nil?

      employment_ended_on = adjusted_end_date(employment)
      other_ended_on = adjusted_end_date(other)

      other.started_on <= employment_ended_on && employment_ended_on <= other_ended_on
    end
  end

  def next_employment_started_within_threshold?(employment, threshold)
    return false unless (next_start = next_employment_start(employment))

    next_start <= employment.ended_on + threshold
  end

  def next_employment_start(employment)
    record.employments
      .reject { |other| other == employment }
      .map(&:started_on)
      .select { |started_on| started_on >= employment.ended_on }
      .min
  end

  def gap_end_date(employment)
    return unless (next_start = next_employment_start(employment))

    next_start
  end

  def adjusted_end_date(employment)
    employment.current_role? ? today : employment.ended_on
  end
end
