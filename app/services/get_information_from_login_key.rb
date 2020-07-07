class GetInformationFromLoginKey
  attr_reader :reason_for_failing_sign_in, :schools, :school_groups

  def initialize(key)
    @key = key
    @key && !@key.expired? ? process_key : deny_sign_in
  end

  def details_to_update_in_session
    { has_multiple_organisations: has_multiple_organisations,
      oid: @user&.oid }
  end

  private

  def deny_sign_in
    if @key&.expired?
      @reason_for_failing_sign_in = 'expired'
    else
      @reason_for_failing_sign_in = 'no_key'
    end
  end

  def process_key
    @user = get_user
    @schools = get_schools
    @school_groups = SchoolGroupJobsFeature.enabled? ? get_school_groups : []
    @key.destroy
    @reason_for_failing_sign_in = 'no_orgs' if @schools.empty? && @school_groups.empty?
  end

  def get_schools
    scratch = []
    @user&.dsi_data&.dig('school_urns')&.each do |urn|
      school_query = School.where(urn: urn)
      scratch.push SchoolPresenter.new(school_query.first) unless school_query.empty?
    end
    scratch.sort_by { |school| school.name }
  end

  def get_school_groups
    scratch = []
    @user&.dsi_data&.dig('school_group_uids')&.each do |uid|
      school_group_query = SchoolGroup.where(uid: uid)
      scratch.push(school_group_query.first) unless school_group_query.empty?
    end
    scratch.sort_by { |school_group| school_group.name }
  end

  def get_user
    @key.user_id ? User.find(@key.user_id) : nil
  end

  def has_multiple_organisations
    @schools ? @schools.size > 1 : nil
  end
end
