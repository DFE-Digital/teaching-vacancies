class VacancyForm
  include ActiveModel::Model

  attr_accessor :vacancy

  delegate(*Vacancy.attribute_names.map { |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten, to: :vacancy)
  delegate :save, to: :vacancy

  def initialize(params = {})
    @vacancy = Vacancy.new(params.except(:expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem))
  end

  def school
    @school ||= vacancy.school
  end
end
