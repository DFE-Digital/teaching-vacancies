require 'rails_helper'
require 'add_dsi_approvers_to_spreadsheet'

RSpec.describe AddDSIApproversToSpreadsheet do
  let(:worksheet) { double(num_rows: 2, save: nil) }
  let(:dfe_sign_in_api) { double(DFESignIn::API) }
  subject { described_class.new }

  let(:response_json_1) do
    json_response(
      "users": [{
        "organisation": {}
      }],
      "numberOfPages": 1
    )
  end

  let(:response_json_2) do
    json_response(
      "users": [{
        "organisation": {}
      }],
      "numberOfPages": 2
    )
  end

  let(:response_json_3) do
    json_response(
      "users": [{
        "organisation": {}
      }],
      "numberOfPages": 3
    )
  end

  let(:unsuccesful_response_json) do
    json_response(
      "success": false,
      "message": 'jwt expired'
    )
  end

  it 'makes an initial request to get the total number of pages' do
    expect(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
    expect(dfe_sign_in_api).to receive(:approvers).and_return(response_json_1)

    subject.send(:total_page_number)
  end

  describe '#total_page_number' do
    it 'returns the number of pages value from the API response' do
      stub_dsi_approver_api_initial_call(response_json_2)

      total_page_num = subject.send(:total_page_number)

      expect(total_page_num).to eq(response_json_2['numberOfPages'])
    end
  end

  describe '#all_service_approvers' do
    context 'when making multiple requests' do
      scenario 'makes one request if there is only one page' do
        stub_dsi_approver_api_initial_call(response_json_1)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(:approvers).with(page: 1)

        subject.all_service_approvers
      end

      scenario 'makes two requests if there are two pages' do
        stub_dsi_approver_api_initial_call(response_json_2)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(:approvers).with(page: 1)
        expect(dfe_sign_in_api).to receive(:approvers).with(page: 2)

        subject.all_service_approvers
      end

      scenario 'make three requests if there are three pages' do
        stub_dsi_approver_api_initial_call(response_json_3)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(:approvers).with(page: 1)
        expect(dfe_sign_in_api).to receive(:approvers).with(page: 2)
        expect(dfe_sign_in_api).to receive(:approvers).with(page: 3)

        subject.all_service_approvers
      end

      scenario 'when an error is raised, it continues with next page' do
        stub_dsi_approver_api_initial_call(response_json_3)
        stub_dsi_approver_api_response_error_for_page(2)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(:approvers).with(page: 1)
        expect(dfe_sign_in_api).to receive(:approvers).with(page: 3)

        subject.all_service_approvers
      end

      scenario 'when there is a error response, logs the error message' do
        stub_dsi_approver_api_initial_call(response_json_3)
        stub_dsi_approver_api_response_for_page(1, response_json_1)
        stub_dsi_approver_api_response_error_for_page(2)
        stub_spreadsheet_writer

        expect(Rails.logger).to receive(:warn).with('DSI API failed to respond at page 2 ' \
           'with error: DFESignIn::ExternalServerError')

        expect(worksheet).to receive(:append_rows).twice

        subject.all_service_approvers
      end
    end

    context 'when there is unsuccessful response' do
      scenario 'has error on first request, does not clear spreadsheet' do
        stub_dsi_approver_api_initial_call(unsuccesful_response_json)
        stub_spreadsheet_writer

        expect(Rails.logger).to receive(:warn).with('DSI API failed to respond ' \
          'with error: ' + unsuccesful_response_json['message'])

        expect(worksheet).to_not receive(:clear_all_rows)
        expect(worksheet).to_not receive(:append_rows)
        subject.all_service_approvers
      end
    end

    context 'when recieving the approver data' do
      it 'initializes the spreadsheet writer with a spreadsheet' do
        stub_dsi_approver_api_initial_call(response_json_1)

        allow(worksheet).to receive(:clear_all_rows)
        allow(worksheet).to receive(:append_rows)

        expect(Spreadsheet::Writer).to receive(:new)
          .with(DSI_USER_SPREADSHEET_ID, DSI_APPROVER_WORKSHEET_GID, true) { worksheet }
        subject.all_service_approvers
      end

      it 'clears the spreadsheet' do
        stub_dsi_approver_api_initial_call(response_json_1)
        stub_spreadsheet_writer

        expect(worksheet).to receive(:clear_all_rows)

        subject.all_service_approvers
      end

      it 'adds approver data to spreadsheet' do
        response_json_page_one = response_file_to_json(1)
        response_json_page_two = response_file_to_json(2)

        expected_spreadsheet_rows_one = map_json_to_rows(response_json_page_one)
        expected_spreadsheet_rows_two = map_json_to_rows(response_json_page_two)

        stub_dsi_approver_api_initial_call(response_json_page_one)
        stub_dsi_approver_api_response_for_page(1, response_json_page_one)
        stub_dsi_approver_api_response_for_page(2, response_json_page_two)

        stub_spreadsheet_writer

        expect(worksheet).to receive(:append_rows).with(expected_spreadsheet_rows_one)
        expect(worksheet).to receive(:append_rows).with(expected_spreadsheet_rows_two)
        subject.all_service_approvers
      end
    end
  end

  def stub_dsi_approver_api_initial_call(response)
    allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
    allow(dfe_sign_in_api).to receive(:approvers).and_return(response)
  end

  def stub_dsi_approver_api_response_for_page(page, response)
    allow(dfe_sign_in_api).to receive(:approvers).with(page: page).and_return(response)
  end

  def stub_dsi_approver_api_response_error_for_page(page)
    allow(dfe_sign_in_api).to receive(:approvers).with(page: page).and_raise(DFESignIn::ExternalServerError)
  end

  def stub_spreadsheet_writer
    allow(Spreadsheet::Writer).to receive(:new)
      .with(DSI_USER_SPREADSHEET_ID, DSI_APPROVER_WORKSHEET_GID, true) { worksheet }

    allow(worksheet).to receive(:delete_rows)
    allow(worksheet).to receive(:clear_all_rows)
    allow(worksheet).to receive(:append_rows)
  end

  def json_response(data)
    JSON.parse(data.to_json)
  end

  def map_json_to_rows(json_response)
    json_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        user['givenName'],
        user['familyName'],
        user['email'],
        user['organisation']['URN'],
        user['organisation']['name'],
        user['organisation']['Status'],
        user['organisation']['phaseOfEducation'],
        user['organisation']['telephone'],
        user['organisation']['regionCode'],
        format_datetime_with_seconds(user['organisation']['createdAt']),
        format_datetime_with_seconds(user['organisation']['updatedAt']),
      ]
    end
  end

  def response_file_to_json(page)
    response_file = File.read(Rails.root.join(
                                'spec', 'fixtures', "dfe_sign_in_service_approvers_response_page_#{page}.json"
                              ))
    JSON.parse(response_file)
  end
end
