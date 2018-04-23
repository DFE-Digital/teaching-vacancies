class Permission
  USER_TO_SCHOOL_MAPPING = {
    'a5161a87-94d6-4723-823b-90d10a5760d6' => '137138', # test@
    '7d842528-52c8-49db-9deb-6bd4d9aaf7c8' => '111692', # fiona@
    '072c5093-522f-42d2-bdd7-4f8eaac13f6a' => '137138', # despo@
    '7cc40258-46ae-484e-8c5f-df1b29409757' => '137138', # gaz@
    'b1217fdd-931c-4763-9d2a-6bb78a5c74fe' => '137138', # hilary@
    '301a4244-b1e4-4449-be41-19aa22653b18' => '137138', # isobel@
    'bbbcc38c-b0fa-4d44-ac8e-c0c833207071' => '137138', # leanne@
    'f7973e5c-8035-42ce-aaaa-31e88d182507' => '137138', # michael@
    '38c07d17-e16b-4607-8b4a-b8cb79e603bc' => '137138', # tom@
    'f53a9c87-2ad7-47cb-af7b-341d0940196d' => '137138' # ellie@
  }.freeze

  def initialize(identifier:)
    @identifier = identifier
  end

  def valid?
    school_urn.present?
  end

  def school_urn
    return ENV['OVERRIDE_SCHOOL_URN'] if !Rails.env.production? && ENV['OVERRIDE_SCHOOL_URN'].present?
    USER_TO_SCHOOL_MAPPING[@identifier]
  end
end
