require 'rails_helper'
require 'export_tables_to_csv_files'
require 'fileutils'

RSpec.describe ExportTablesToCSVFiles do
  before do
    FileUtils.rm_rf(Rails.root.join('tmp/csv_export'))

    create_list(:vacancy, 2)

    described_class.new.run!
  end

  let(:vacancies_csv_file) { (Rails.root.join('tmp/csv_export/vacancy.csv')) }
  let(:vacancies_csv_rows) { File.readlines(vacancies_csv_file) }

  let(:users_csv_file) { Rails.root.join('tmp/csv_export/user.csv') }

  it 'inserts the record attributes as headers' do
    expect(vacancies_csv_rows.first).to match(Vacancy.first.attributes.keys.join(','))
  end

  it 'inserts record attribute and data' do
    expect(vacancies_csv_rows.size).to eq(3)
  end

  it 'does not create a CSV file if there are no records' do
    expect(File.exist?(users_csv_file)).to be false
  end
end
