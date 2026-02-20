class SchoolGroup < Organisation
  has_many :school_group_memberships, dependent: :destroy
  has_many :schools, through: :school_group_memberships

  def key_stages
    schools.map(&:key_stages).flatten.uniq.compact
  end

  def live_group_vacancies
    Vacancy.none
  end

  def profile_complete?
    return true unless trust?

    super && schools.all?(&:profile_complete?)
  end

  def faith_school?
    false
  end

  def all_organisations
    [self] + schools + schools_outside_local_authority
  end

  def all_organisation_ids
    [id] + schools.pluck(:id) + schools_outside_local_authority.pluck(:id)
  end

  def ats_interstitial_variant
    "non_faith"
  end
end
