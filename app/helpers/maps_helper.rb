module MapsHelper
  def vacancy_map_markers(vacancies, polygon, coordinates, radius) # rubocop:disable Metrics/MethodLength
    organisation_ids = Organisation.in_vacancy_ids(vacancies.pluck(:id))
                                   .within_polygon(polygon)
                                   .within_area(coordinates, radius)
                                   .pluck(:id)

    vacancies.map { |vacancy|
      vacancy.organisations.select { |organisation| organisation.id.in?(organisation_ids) }.map do |organisation|
        {
          geopoint: organisation.geopoint,
          heading: govuk_link_to(vacancy.job_title, job_path(vacancy)),
          address: full_address(organisation),
          details: [
            { label: t("jobs.salary"), value: salary_value(vacancy) },
            { label: organisation_type_label(vacancy), value: organisation_type(organisation) },
            { label: t("jobs.working_patterns"), value: vacancy.readable_working_patterns },
            { label: t("jobs.expires_at"), value: format_time_to_datetime_at(vacancy.expires_at) },
          ],
        }
      end
    }.flatten
  end

  def organisation_map_markers(vacancy)
    vacancy.organisations.map do |organisation|
      {
        geopoint: organisation.geopoint,
        heading: map_link(organisation.name, organisation.url, vacancy_id: vacancy.id),
        description: organisation_type(organisation),
        address: full_address(organisation),
      }
    end
  end
end
