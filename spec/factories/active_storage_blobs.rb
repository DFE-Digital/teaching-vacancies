# frozen_string_literal: true

FactoryBot.define do
  factory :active_storage_blob, class: "ActiveStorage::Blob" do
    filename { "test_file.pdf" }
    content_type { "application/pdf" }
    byte_size { 1024 }
    checksum { Digest::MD5.base64digest("test content") }
    service_name { "azure_storage_documents" }
    key { SecureRandom.uuid }
    malware_scan_result { :pending }

    trait :clean do
      malware_scan_result { :clean }
    end

    trait :malicious do
      malware_scan_result { :malicious }
    end

    trait :scan_error do
      malware_scan_result { :scan_error }
    end
  end
end
