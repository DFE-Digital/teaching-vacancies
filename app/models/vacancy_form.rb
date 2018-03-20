class VacancyForm
  include ActiveModel::Model

  attr_accessor :vacancy

  def initialize(params = {})
    @vacancy = ::Vacancy.new(params)
  end

  delegate :save, to: :vacancy
end
