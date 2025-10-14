FactoryBot.define do
  factory :message_template do
    template_type { :rejection }
    name { Faker::Fantasy::Tolkien.character }
    content { Faker::Fantasy::Tolkien.poem }
  end
end
