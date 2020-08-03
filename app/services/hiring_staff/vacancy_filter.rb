class HiringStaff::VacancyFilter
  attr_reader :managed_school_urns, :managed_organisations

  def initialize(user, school_group)
    @user_preference = UserPreference.find_or_initialize_by(user: user, school_group: school_group)
    @managed_school_urns = @user_preference.managed_school_urns
    @managed_organisations = @user_preference.managed_organisations
  end

  def update(params)
    @managed_school_urns = params[:managed_school_urns]&.reject(&:blank?)
    @managed_organisations = params[:managed_organisations]

    if managed_organisations&.include?('all') || (managed_organisations.blank? && managed_school_urns&.none?)
      @managed_organisations = 'all'
      @managed_school_urns = []
    elsif managed_organisations&.include?('school_group')
      @managed_organisations = 'school_group'
    end

    @user_preference.update(managed_organisations: managed_organisations, managed_school_urns: managed_school_urns)
  end

  def to_h
    {
      managed_organisations: managed_organisations,
      managed_school_urns: managed_school_urns
    }
  end
end
