class GetInformationFromLoginKey
  attr_reader :reason_for_failing_sign_in, :schools

  def initialize(key)
    @key = key
    @key && !@key.expired? ? process_key : set_reason_for_failing_sign_in
  end

  def details_to_update_in_session
    { has_multiple_schools: has_multiple_schools,
      oid: @user&.oid }
  end

  private

  def set_reason_for_failing_sign_in
    if @key&.expired?
      @reason_for_failing_sign_in = 'expired'
    else
      @reason_for_failing_sign_in = 'no_key'
    end
  end

  def process_key
    @user = @key.user_id ? User.find(@key.user_id) : nil
    @key.destroy
    @schools = get_schools
    # TODO: include school_groups here when we have implemented school groups/trusts/LAs
    @reason_for_failing_sign_in = 'no_orgs' if @schools.empty?
  end

  def get_schools
    scratch = []
    @user&.dsi_data&.dig('school_urns')&.each do |urn|
      school_query = School.where(urn: urn)
      scratch.push SchoolPresenter.new(school_query.first) unless school_query.empty?
    end
    scratch.sort_by { |school| school.name }
  end

  def has_multiple_schools
    @schools ? @schools.size > 1 : nil
  end
end
