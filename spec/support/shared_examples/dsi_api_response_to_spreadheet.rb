RSpec.shared_examples 'a DFE API response to spreadsheet' do
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
    expect(dfe_sign_in_api).to receive(endpoint).and_return(response_json_1)

    subject.send(:total_page_number, endpoint)
  end

  describe '#total_page_number' do
    it 'returns the number of pages value from the API response' do
      stub_dsi_api_initial_call(response_json_2)

      total_page_num = subject.send(:total_page_number, endpoint)

      expect(total_page_num).to eq(response_json_2['numberOfPages'])
    end
  end

  describe 'all_service_#endpoint' do
    context 'when making multiple requests' do
      scenario 'makes one request if there is only one page' do
        stub_dsi_api_initial_call(response_json_1)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(endpoint).with(page: 1)

        subject.send("all_service_#{endpoint}".to_sym)
      end

      scenario 'makes two requests if there are two pages' do
        stub_dsi_api_initial_call(response_json_2)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(endpoint).with(page: 1)
        expect(dfe_sign_in_api).to receive(endpoint).with(page: 2)

        subject.send("all_service_#{endpoint}".to_sym)
      end

      scenario 'make three requests if there are three pages' do
        stub_dsi_api_initial_call(response_json_3)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(endpoint).with(page: 1)
        expect(dfe_sign_in_api).to receive(endpoint).with(page: 2)
        expect(dfe_sign_in_api).to receive(endpoint).with(page: 3)

        subject.send("all_service_#{endpoint}".to_sym)
      end

      scenario 'when an error is raised the task terminates at the faulty page' do
        stub_dsi_api_initial_call(response_json_3)
        stub_dsi_api_response_error_for_page(2)
        stub_spreadsheet_writer

        expect(dfe_sign_in_api).to receive(endpoint).with(page: 1)
        expect(dfe_sign_in_api).to receive(endpoint).with(page: 2)
        expect(dfe_sign_in_api).not_to receive(endpoint).with(page: 3)

        expect { subject.send("all_service_#{endpoint}".to_sym) }
        .to raise_error(DFESignIn::ExternalServerError)
      end

      scenario 'when there is a error response, logs the error message and re-raises the error' do
        stub_dsi_api_initial_call(response_json_3)
        stub_dsi_api_response_for_page(1, response_json_1)
        stub_dsi_api_response_error_for_page(2)
        stub_spreadsheet_writer

        expect(Rails.logger).to receive(:warn).with("DSI API #{endpoint} failed to respond at page 2 " \
        'with error: DFESignIn::ExternalServerError')
        expect(Rails.logger).to receive(:warn)
        .with("DSI API #{endpoint} failed to respond with error: DFESignIn::ExternalServerError")

        expect(worksheet).to receive(:append_rows).once

        expect { subject.send("all_service_#{endpoint}".to_sym) }.to raise_error(DFESignIn::ExternalServerError)
      end

      scenario 'when there is a missing key, it returns null for the field' do
        stub_dsi_api_initial_call(response_json_1)
        stub_dsi_api_response_for_page(1, response_json_1)
        stub_spreadsheet_writer

        expect(Rails.logger).not_to receive(:warn)
        .with("DSI API #{endpoint} failed to respond at page 1 with error: undefined method `[]' for nil:NilClass")

        expect { subject.send("all_service_#{endpoint}".to_sym) }.not_to raise_error
      end
    end

    context 'when there is unsuccessful response' do
      scenario 'has error on first request, does not clear spreadsheet' do
        stub_dsi_api_initial_call(unsuccesful_response_json)
        stub_spreadsheet_writer

        expect(Rails.logger).to receive(:warn).with("DSI API #{endpoint} failed to respond " \
          'with error: ' + unsuccesful_response_json['message'])

        expect(worksheet).to_not receive(:clear_all_rows)
        expect(worksheet).to_not receive(:append_rows)

        expect { subject.send("all_service_#{endpoint}".to_sym) }.to raise_error(RuntimeError, /jwt expired/)
      end
    end

    context 'when recieving the endpoit data' do
      it 'initializes the spreadsheet writer with a spreadsheet' do
        stub_dsi_api_initial_call(response_json_1)

        allow(worksheet).to receive(:clear_all_rows)
        allow(worksheet).to receive(:append_rows)

        expect(Spreadsheet::Writer).to receive(:new)
          .with(DSI_USER_SPREADSHEET_ID, dsi_worksheet_gid, true) { worksheet }
        subject.send("all_service_#{endpoint}".to_sym)
      end

      it 'clears the spreadsheet' do
        stub_dsi_api_initial_call(response_json_1)
        stub_spreadsheet_writer

        expect(worksheet).to receive(:clear_all_rows)

        subject.send("all_service_#{endpoint}".to_sym)
      end

      it 'adds data to spreadsheet' do
        response_json_page_one = response_file_to_json(1)
        response_json_page_two = response_file_to_json(2)

        stub_dsi_api_initial_call(response_json_page_one)
        stub_dsi_api_response_for_page(1, response_json_page_one)
        stub_dsi_api_response_for_page(2, response_json_page_two)

        stub_spreadsheet_writer

        expect(worksheet).to receive(:append_rows).with(expected_spreadsheet_rows_one)
        expect(worksheet).to receive(:append_rows).with(expected_spreadsheet_rows_two)
        subject.send("all_service_#{endpoint}".to_sym)
      end
    end
  end

  def stub_dsi_api_initial_call(response)
    allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
    allow(dfe_sign_in_api).to receive(endpoint).and_return(response)
  end

  def stub_dsi_api_response_for_page(page, response)
    allow(dfe_sign_in_api).to receive(endpoint).with(page: page).and_return(response)
  end

  def stub_dsi_api_response_error_for_page(page)
    allow(dfe_sign_in_api).to receive(endpoint).with(page: page).and_raise(DFESignIn::ExternalServerError)
  end

  def stub_spreadsheet_writer
    allow(Spreadsheet::Writer).to receive(:new)
      .with(DSI_USER_SPREADSHEET_ID, dsi_worksheet_gid, true) { worksheet }

    allow(worksheet).to receive(:delete_rows)
    allow(worksheet).to receive(:clear_all_rows)
    allow(worksheet).to receive(:append_rows)
  end

  def json_response(data)
    JSON.parse(data.to_json)
  end

  def response_file_to_json(page)
    response_file = File.read(Rails.root.join(
                                'spec', 'fixtures', "dfe_sign_in_service_#{endpoint}_response_page_#{page}.json"
                              ))
    JSON.parse(response_file)
  end
end
