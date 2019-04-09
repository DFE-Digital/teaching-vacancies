RSpec.shared_examples_for 'ExportToSpreadsheet' do
  let(:worksheet) { double(num_rows: 2, save: nil) }
  let(:gids) do
    {
      vacancies: 'some-gid',
      feedback: 'feedback-gid',
      interest_expression: 'interest-expression-gid'
    }
  end

  before do
    stub_const(spreadsheet_id, 'abc1-def2')
    stub_const('AUDIT_GIDS', gids)
    allow(Spreadsheet::Writer).to receive(:new).with(AUDIT_SPREADSHEET_ID, gids[category.to_sym], true) { worksheet }
  end

  context 'when there is new data' do
    before do
      allow(worksheet).to receive(:last_row) { [1.day.ago.to_s, 7, 8, 9] }
    end

    it 'gets the new data' do
      results = subject.send(:results)

      expect(results.count).to eq(3)

      expect(results.first).to eq(new_data.first)
      expect(results.last).to eq(new_data.last)
    end

    it 'adds the new data to the spreadsheet' do
      data = new_data.map(&:to_row)
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
      data = (existing_data + new_data).map(&:to_row)
      expect(worksheet).to receive(:append_rows).with(data)
      subject.run!
    end
  end
end