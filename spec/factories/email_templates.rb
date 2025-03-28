FactoryBot.define do
  factory :email_template do
    subject { Faker::Internet.domain_word }
    name { Faker::Fantasy::Tolkien.character }
    from { Faker::Educator.campus }
    content { Faker::Fantasy::Tolkien.poem }
  end
end
