require 'rails_helper'
require 'export_dsi_users_to_big_query'

RSpec.describe ExportDsiUsersToBigQuery do
  before do
    ENV['BIG_QUERY_DATASET'] = 'test_dataset'
    expect(bigquery_stub).to receive(:dataset).with('test_dataset').and_return(dataset_stub)
    expect(dataset_stub).to receive(:table).and_return(table_stub)

    expect(DFESignIn::API).to receive(:new).at_least(:once).and_return(dfe_sign_in_api)
    expect(dfe_sign_in_api).to receive(:users).at_least(:once).and_return(api_response)
  end

  subject { ExportDsiUsersToBigQuery.new(bigquery: bigquery_stub) }

  let(:bigquery_stub) { instance_double('Google::Cloud::Bigquery::Project') }
  let(:dataset_stub) { instance_double('Google::Cloud::Bigquery::Dataset') }

  let(:dfe_sign_in_api) { double(DFESignIn::API) }
  let(:number_of_pages) { 1 }
  let(:api_response) { succesful_api_response }

  let(:succesful_api_response) do
    json_response(
      "users": [user],
      "numberOfPages": number_of_pages
    )
  end

  let(:unsuccesful_api_response) do
    json_response(
      "success": false,
      "message": 'jwt expired'
    )
  end

  let(:user) {
    {
      'userId' => SecureRandom.uuid,
      'role' => ['End user', 'Approver'].sample,
      'approval_datetime' => 3.weeks.ago,
      'update_datetime' => 2.weeks.ago,
      'given_name' => Faker::Name.first_name,
      'family_name' => Faker::Name.last_name,
      'email' => Faker::Internet.email,
      'organisation' => { 'URN' => 100000 }
    }
  }

  let(:expected_table_data) do
    [
      {
        user_id: user['userId'],
        role: user['roleName'],
        approval_datetime: user['approvedAt'],
        update_datetime: user['updatedAt'],
        given_name: user['givenName'],
        family_name: user['familyName'],
        email: user['email'],
        school_urn: user['organisation']['URN']
      }
    ]
  end

  context 'when the user table exists in the dataset' do
    let(:table_stub) { instance_double('Google::Cloud::Bigquery::Table') }

    it 'deletes the table first before inserting new table data' do
      expect(table_stub).to receive(:delete).and_return(true)
      expect(dataset_stub).to receive(:reload!)
      expect(dataset_stub).to receive(:insert)

      subject.run!
    end
  end

  context 'when the user table does not exist in the dataset' do
    let(:table_stub) { nil }

    context 'when DSI API is up and running' do
      it 'invokes insert on the dataset' do
        expect(dataset_stub).to receive(:insert).with('dsi_users', expected_table_data, autocreate: true)

        subject.run!
      end
    end

    context 'when DSI API fails' do
      let(:api_response) { unsuccesful_api_response }

      it 'raises a runtime error' do
        expect { subject.run! }.to raise_error(RuntimeError)
      end
    end
  end

  def json_response(data)
    JSON.parse(data.to_json)
  end
end
