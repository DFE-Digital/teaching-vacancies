FactoryBot.define do
  factory :document do
    name { 'Test.png' }
    size { 10_000 }
    content_type { 'image/png' }
    download_url { 'test/test.png' }
    google_drive_id { 'testid' }
    vacancy
  end
end
