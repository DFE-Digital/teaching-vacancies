class VacancyPresenter < BasePresenter

  def total_pages
    model.total_pages
  end

  def salary_range(del="-")
    model.maximum_salary.blank? ?
      number_to_currency(model.minimum_salary) :
      "#{number_to_currency(model.minimum_salary)} #{del} #{number_to_currency(model.maximum_salary)}"
  end

  def location
    @location ||= school.location
  end

  def expired?
    model.expires_on < Time.zone.today
  end

  def school
    @school ||= SchoolPresenter.new(model.school)
  end

  def main_subject
    @main_subject ||= model.subject ? model.subject.name : ""
  end

  def pay_scale
    @pay_scale ||= model.pay_scale ? model.pay_scale.label : ""
  end

  def publish_today?
    model.publish_on == Time.zone.today
  end
end
