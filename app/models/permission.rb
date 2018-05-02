class Permission
  HIRING_STAFF_USER_TO_SCHOOL_MAPPING = {
    '38c07d17-e16b-4607-8b4a-b8cb79e603bc' => '137138', # tom@
    '65adc1e9-3a8c-4392-babe-444f1618da60' => '143291', # qehs@
    '60259165-9f06-4e2e-9dbf-ce84ec5085f0' => '141297', # cromwellacademy@
    'd1b3cdd6-a02b-48e7-8b38-a5eb9d2f0044' => '137475', # hinchbk@
    '2e38e584-572b-41c5-bc0a-5ef9e05812a3' => '138088', # springfield@
    '31c327a7-3cbd-4d84-ad5f-bc82802d0e4a' => '108531', # heatonmanor@
    '348db94b-5331-45f4-90c3-f61698eeb78d' => '111669', # thornaby.stockton@
    'dee1927f-ce4f-40c3-8755-0517b54fe27c' => '108513', # stteresas@
    'b86cd643-f811-4574-8b9f-fc9cfbb9a210' => '130908', # macmillan-academy@
    '2a761502-7ebd-4358-b19d-3ef6b006735f' => '111637', # lps.rac@
    'd9181457-126d-4860-b50e-659122cebd8c' => '136775', # sawstonvc@
    '90604155-14d0-4bb3-9af0-9a8b9f90df63' => '136580', # swaveseyvc@
  }.freeze

  TEAM_USER_TO_SCHOOL_MAPPING = {
    'a5161a87-94d6-4723-823b-90d10a5760d6' => '137138', # test@
    '7d842528-52c8-49db-9deb-6bd4d9aaf7c8' => '111692', # fiona@
    '072c5093-522f-42d2-bdd7-4f8eaac13f6a' => '137138', # despo@
    '7cc40258-46ae-484e-8c5f-df1b29409757' => '137138', # gaz@
    'b1217fdd-931c-4763-9d2a-6bb78a5c74fe' => '137138', # hilary@
    '301a4244-b1e4-4449-be41-19aa22653b18' => '137138', # isobel@
    'bbbcc38c-b0fa-4d44-ac8e-c0c833207071' => '137138', # leanne@
    'f7973e5c-8035-42ce-aaaa-31e88d182507' => '137138', # michael@
    '38c07d17-e16b-4607-8b4a-b8cb79e603bc' => '137138', # tom@
    'f53a9c87-2ad7-47cb-af7b-341d0940196d' => '137138', # ellie@
  }.freeze

  def initialize(identifier:)
    @identifier = identifier
  end

  def valid?
    school_urn.present?
  end

  def school_urn
    return ENV['OVERRIDE_SCHOOL_URN'] if !Rails.env.production? && ENV['OVERRIDE_SCHOOL_URN'].present?
    if !Rails.env.production? && TEAM_USER_TO_SCHOOL_MAPPING.key?(@identifier)
      return TEAM_USER_TO_SCHOOL_MAPPING[@identifier]
    end

    HIRING_STAFF_USER_TO_SCHOOL_MAPPING[@identifier]
  end
end
