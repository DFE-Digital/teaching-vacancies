class HiringStaff::VacancyFilter
  attr_reader :managed_school_ids, :managed_organisations

  def initialize(user, school_group)
    @user_preference = UserPreference.find_or_initialize_by(user: user, school_group: school_group)
    @managed_school_ids = @user_preference.managed_school_ids
    @managed_organisations = @user_preference.managed_organisations
  end

  def update(params)
    @managed_school_ids = params[:managed_school_ids]&.reject(&:blank?)
    @managed_organisations = params[:managed_organisations]

    if managed_organisations&.include?('all') || (managed_organisations.blank? && managed_school_ids&.none?)
      @managed_organisations = 'all'
      @managed_school_ids = []
    end

    @user_preference.update(managed_organisations: managed_organisations, managed_school_ids: managed_school_ids)
  end

  def to_h
    {
      managed_organisations: managed_organisations,
      managed_school_ids: managed_school_ids
    }
  end
end
