module DateAttributeAssignment
  private

  def date_from_multiparameter_hash(date_params)
    date = ActiveModel::Type::Date.new.cast(date_params)
    return date unless date.nil? && date_params&.values&.any?(&:present?)

    date_params
  rescue ArgumentError
    date_params
  end

  def datetime_from_date_and_time(date, time)
    return unless date.is_a?(Date)

    Time.zone.parse("#{date} #{time}")
  end
end
