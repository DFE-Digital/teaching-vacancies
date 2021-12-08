class VacancySelectorComponent < GovukComponent::Base
  def initialize(vacancies, organisation:, label_text:, classes: [], html_attributes: {}, **kwargs)
    super(classes: classes, html_attributes: html_attributes, **kwargs)

    @label_text = label_text
    @organisation = organisation
    @vacancies = vacancies
  end

  private

  attr_reader(*%i[
    label_text
    organisation
    vacancies
  ])
end
