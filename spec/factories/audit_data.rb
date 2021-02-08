FactoryBot.define do
  factory :audit_data do
    category { 0 }
    data { { foo: "bar" } }
  end
end
