require 'rails_helper'
require 'add_audit_data'

RSpec.describe AddAuditData do
  subject { described_class.new('vacancies') }

  let(:worksheet) { double(num_rows: 2, save: nil) }

  let!(:existing_data) { Timecop.freeze(2.days.ago) { create_list(:audit_data, 3, category: 'vacancies') } }
  let!(:new_data) { create_list(:audit_data, 3, category: 'vacancies') }
  let!(:other_data) { create_list(:audit_data, 3, category: 'sign_in_events') }

  before do
    gids = { vacancies: 'some-gid' }
    stub_const('AUDIT_SPREADSHEET_ID', 'abc1-def2')
    stub_const('AUDIT_GIDS', gids)
    allow(Spreadsheet::Writer).to receive(:new).with(AUDIT_SPREADSHEET_ID, gids[:vacancies], true) { worksheet }
  end

  context 'when there is new data' do
    before do
      allow(worksheet).to receive(:last_row) { [1.day.ago.to_s, 7, 8, 9] }
    end

    it 'gets the new data' do
      results = subject.send(:results)

      expect(results.count).to eq(3)

      expect(results.first.data).to eq(new_data.first.data)
      expect(results.last.data).to eq(new_data.last.data)
    end

    it 'adds the new data to the spreadsheet' do
      data = new_data.map { |d| d.data.values.unshift(d.created_at.to_s) }
      expect(worksheet).to receive(:append_rows).with(data)
      subject.run!
    end
  end

  context 'when there is no new data' do
    before do
      allow(worksheet).to receive(:last_row) { [(Time.zone.now + 1.hour).to_s, 7, 8, 9] }
    end

    it 'returns no new data' do
      results = subject.send(:results)

      expect(results.count).to eq(0)
    end

    it 'adds nothing to the spreadsheet' do
      expect(worksheet).to receive(:append_rows).with([])
      subject.run!
    end
  end

  context 'when the worksheet is empty' do
    before do
      allow(worksheet).to receive(:last_row) { nil }
    end

    it 'adds all the data to the spreadsheet' do
      data = (existing_data + new_data).map { |d| d.data.values.unshift(Time.zone.now.to_s) }
      expect(worksheet).to receive(:append_rows).with(data)
      subject.run!
    end
  end
end