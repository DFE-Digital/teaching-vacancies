class Publishers::NoVacanciesComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.all_vacancies.active.none?
  end

  def heading
    if @organisation.group_type == "local_authority"
      t("schools.jobs.local_authority_index_html", organisation: @organisation.name)
    else
      t("schools.jobs.index_html", organisation: @organisation.name)
    end
  end
end
