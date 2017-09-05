FactoryGirl.define do
  factory :pay_scale do
    label do
      [
        'Main pay range 1',
        'Main pay range 2',
        'Main pay range 3',
        'Main pay range 4',
        'Main pay range 5',
        'Main pay range 6',
        'Upper pay range 1',
        'Upper pay range 2',
        'Upper pay range 3',
      ].sample
    end
  end
end