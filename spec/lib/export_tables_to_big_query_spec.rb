require 'rails_helper'
require 'export_tables_to_big_query'

RSpec.describe ExportTablesToBigQuery do
  let(:bigquery) do
    double('bigquery', dataset: dataset)
  end

  let(:dataset) do
    double('dataset').as_null_object
  end

  let(:storage) do
    double('storage').as_null_object
  end

  subject do
    described_class.new(bigquery: bigquery, storage: storage)
  end

  before do
    allow(Dir).to receive(:children).and_return([])
  end

  describe '#run!' do
    before do
      allow(ApplicationRecord.connection).to receive(:tables).and_return(tables)
      allow_any_instance_of(String).to receive(:constantize).and_return(table)
    end

    context 'when a table has no records' do
      let(:tables) do
        %w[empty_table]
      end

      let(:table) do
        double('EmptyTable', count: 0, none?: true)
      end

      it 'an empty json tmpfile does not get created for that table' do
        expect(File).not_to receive(:new).with(an_instance_of(Pathname), 'w')
        subject.run!
      end
    end

    context 'when a table has records' do
      let(:tables) do
        %w[table_with_records]
      end

      let(:table) do
        double('TableWithRecords', count: 1, none?: false).as_null_object
      end

      it 'a json tmpfile gets created for that table' do
        expect(File).to receive(:new).with(an_instance_of(Pathname), 'w').and_return(double.as_null_object)
        subject.run!
      end
    end
  end
end
