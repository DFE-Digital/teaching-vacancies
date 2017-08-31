FactoryGirl.define do
  factory :leadership do
    title do
      [
        'Middle Leader',
        'Senior Leader',
        'Headteacher',
        'Executive Head',
        'Multi-Academy Trust',
      ].sample
    end
  end
end