class VacancyForm
  include ActiveModel::Model

  attr_accessor :vacancy

  delegate *Vacancy.attribute_names.map { |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten, to: :vacancy
  delegate :save, to: :vacancy

  def initialize(params = {})
    @vacancy = ::Vacancy.new(params)
  end

  def school
    @school ||= vacancy.school
  end
end
