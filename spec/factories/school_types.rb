FactoryGirl.define do
  factory :school_type do
    label do
      [
        'Academy',
        'Independent School',
        'Free School',
        'LA Maintained School',
        'Special School',
      ].sample
    end
  end
end