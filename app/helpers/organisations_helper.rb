module OrganisationsHelper
  def location(organisation)
    return organisation.location if organisation.is_a?(SchoolPresenter)

    school_group_fields = [
      'Group Contact Address 3',
      'Group Contact Town',
      'Group Contact County',
      'Group Contact Postcode'
    ]
    organisation.gias_data.slice(*school_group_fields)
                          .values
                          .select(&:present?)
                          .join(', ')
  end
end
