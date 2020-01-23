require 'rails_helper'
require 'export_tables_to_cloud_storage'
require 'fileutils'

RSpec.describe ExportTablesToCloudStorage do
  before do
    FileUtils.rm_rf(Rails.root.join('tmp/csv_export'))

    create :user

    expect(cloud_storage_stub).to receive(:bucket).with(ENV['CLOUD_STORAGE_BUCKET']).and_return(bucket_stub)
  end

  subject { ExportTablesToCloudStorage.new(storage: cloud_storage_stub) }

  let(:cloud_storage_stub) { instance_double('Google::Cloud::Storage::Project') }
  let(:bucket_stub) { instance_double('Google::Cloud::Storage::Bucket') }

  it 'creates a file into the bucket' do
    expect(bucket_stub).to receive(:create_file).with('tmp/csv_export/user.csv', 'csv_export/user.csv')

    subject.run!
  end

  it 'removes the folder from the file system' do
    expect(bucket_stub).to receive(:create_file).at_least(:once)

    subject.run!

    expect(File.exist?(Rails.root.join('tmp/csv_export'))).to be false
  end
end
