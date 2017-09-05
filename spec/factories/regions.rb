FactoryGirl.define do
  factory :region do
    name do
      [
        'South East England',
        'London',
        'South West England',
        'Yorkshire and the Humber',
        'North West England',
        'West Midlands',
        'East Midlands',
        'North East England',
      ].sample
    end
  end
end