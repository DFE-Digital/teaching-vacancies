FactoryGirl.define do
  factory :subject do
    name do
      [
        'English',
        'Mathematics',
        'Science',
        'Art and design',
        'Citizenship',
        'Computing',
        'Design and technology',
        'Geography',
        'History',
        'Languages',
        'Music',
        'Physical education',
      ].sample
    end
  end
end