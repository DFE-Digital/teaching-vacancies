module DateAttributeAssignment
  private

  def date_from_multiparameter_hash(date_params)
    Date.new(date_params[1], date_params[2], date_params[3])
  rescue ArgumentError, TypeError, NoMethodError
    date_params
  end

  def datetime_from_date_and_time(date, time)
    return date unless date.is_a?(Date)

    Time.zone.parse("#{date} #{time}")
  end
end
