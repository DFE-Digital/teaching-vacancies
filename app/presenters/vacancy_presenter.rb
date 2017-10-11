class VacancyPresenter < BasePresenter

  def total_pages
    model.total_pages
  end

  def salary_range(del="-")
    model.maximum_salary.blank? ?
      number_to_currency(model.minimum_salary) :
      "#{number_to_currency(model.minimum_salary)} #{del} #{number_to_currency(model.maximum_salary)}"
  end
end
