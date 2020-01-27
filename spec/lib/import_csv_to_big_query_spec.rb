require 'import_csv_to_big_query'
RSpec.describe ImportCSVToBigQuery do
  let(:table) { double('table').as_null_object }
  let(:loaded_job) { double('loaded job').as_null_object }
  let(:dataset) { double('dataset').as_null_object }
  let(:bigquery_client) { double('Bigquery Client', dataset: dataset) }
  let(:export_tables) { class_double(ExportTablesToCloudStorage, TABLES: %w[TestTable]) }

  it 'loads the dataset from ENV' do
    expect(ENV).to receive(:[]).with('BIG_QUERY_DATASET').and_return('test')
    subject.load(bigquery: double('BigqueryClient').as_null_object)
  end

  it 'connects to the correct data set' do
    expect(bigquery_client).to receive(:dataset)
    subject.load(bigquery: bigquery_client)
  end

  it 'processes at least one table' do
    expect(ExportTablesToCloudStorage::TABLES).to receive(:each)
    subject.load(bigquery: bigquery_client)
  end

  context 'dataset#load_job' do
    before do
      allow(bigquery_client).to receive(:dataset).and_return(dataset)
      allow(dataset).to receive(:load_job).and_return(loaded_job)
    end

    it 'loads the dataset' do
      expect(dataset).to receive(:load_job).with('vacancy', /vacancy\.csv/, anything)
      subject.load(bigquery: bigquery_client)
    end

    it 'sets skip_leading: 1 when loading the dataset' do
      expect(dataset).to receive(:load_job).with(anything, anything, hash_including(skip_leading: 1))
      subject.load(bigquery: bigquery_client)
    end

    it 'sets autodetect: true when loading the dataset' do
      expect(dataset).to receive(:load_job).with(anything, anything, hash_including(autodetect: true))
      subject.load(bigquery: bigquery_client)
    end

    it 'sets write: "truncate" when loading the dataset' do
      expect(dataset).to receive(:load_job).with(anything, anything, hash_including(write: 'truncate'))
      subject.load(bigquery: bigquery_client)
    end

    it 'waits for the job to finish' do
      expect(loaded_job).to receive(:wait_until_done!)
      subject.load(bigquery: bigquery_client)
    end
  end

  it 'returns the loaded table for reporting purposes' do
    allow(bigquery_client).to receive(:dataset).and_return(dataset)
    expect(dataset).to receive(:table).with('vacancy')
    subject.load(bigquery: bigquery_client)
  end

  context 'dataset#table' do
    before do
      allow(bigquery_client).to receive(:dataset).and_return(dataset)
      allow(dataset).to receive(:table).and_return(table)
    end

    it 'reports the table rows count' do
      expect(table).to receive(:rows_count)
      subject.load(bigquery: bigquery_client)
    end

    it 'reports the table id' do
      expect(table).to receive(:id)
      subject.load(bigquery: bigquery_client)
    end
  end
end
