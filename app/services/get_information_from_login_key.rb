class GetInformationFromLoginKey
  attr_reader :reason_for_failing_sign_in, :schools, :trusts, :local_authorities

  def initialize(key)
    @key = key
    @key && !@key.expired? ? process_key : deny_sign_in
  end

  def details_to_update_in_session
    { multiple_organisations: multiple_organisations?,
      oid: @user&.oid }
  end

  def multiple_organisations?
    # .to_i used to convert nil to 0
    @schools&.count.to_i + @trusts&.count.to_i + @local_authorities&.count.to_i > 1
  end

private

  def deny_sign_in
    @reason_for_failing_sign_in = if @key&.expired?
                                    'expired'
                                  else
                                    'no_key'
                                  end
  end

  def process_key
    @user = get_user
    @schools = get_schools
    @trusts = get_trusts
    @local_authorities = get_local_authorities
    @key.destroy
    @reason_for_failing_sign_in = 'no_orgs' if @schools.empty? && @trusts.empty? && @local_authorities.empty?
  end

  def get_user
    @key.user_id ? User.find(@key.user_id) : nil
  end

  def get_schools
    scratch = []
    @user&.dsi_data&.dig('school_urns')&.each do |urn|
      school_query = School.where(urn: urn)
      scratch.push school_query.first unless school_query.empty?
    end
    scratch.sort_by(&:name)
  end

  def get_trusts
    scratch = []
    @user&.dsi_data&.dig('trust_uids')&.each do |uid|
      school_group_query = SchoolGroup.where(uid: uid)
      scratch.push(school_group_query.first) unless school_group_query.empty?
    end
    scratch.sort_by(&:name)
  end

  def get_local_authorities
    return [] unless LocalAuthorityAccessFeature.enabled?

    scratch = []
    @user&.dsi_data&.dig('la_codes')&.each do |la_code|
      school_group_query = SchoolGroup.where(local_authority_code: la_code, group_type: 'local_authority')
      scratch.push(school_group_query.first) unless school_group_query.empty?
    end
    scratch.sort_by(&:name)
  end
end
