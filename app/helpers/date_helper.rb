module DateHelper
  def format_date(date, format = '%d/%m/%Y')
    date.strftime(format)
  end
end
