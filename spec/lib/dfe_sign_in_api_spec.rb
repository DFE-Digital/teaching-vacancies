require 'rails_helper'
require 'dfe_sign_in_api'

RSpec.describe DFESignIn::API do
  describe '#users' do
    it 'returns the users from the API ' do
      stub_api_response_for_page(1)
      response = described_class.new.users

      expect(response).to eq(JSON.parse(response_file(1)))
      expect(response['page']).to eq(1)
      expect(response['numberOfPages']).to eq(2)
    end

    it 'returns the users from the API for a given page ' do
      stub_api_response_for_page(2)
      response = described_class.new.users(page: 2)

      expect(response).to eq(JSON.parse(response_file(2)))
      expect(response['page']).to eq(2)
      expect(response['numberOfPages']).to eq(2)
    end

    it 'sets a token in the header of the request' do
      Timecop.freeze(Time.zone.now) do
        payload = {
          iss: 'schooljobs',
          exp: (Time.now.getlocal + 60).to_i,
          aud: 'signin.education.gov.uk'
        }

        expected_token = JWT.encode(payload, DFE_SIGN_IN_PASSWORD, 'HS256')

        stub_api_response_for_page(2)
        described_class.new.users(page: 2)

        expect(a_request(:get, "#{DFE_SIGN_IN_URL}/users?page=2&pageSize=25")
          .with(headers: { 'Authorization' => "Bearer #{expected_token}" }))
          .to have_been_made
      end
    end

    def response_file(page)
      File.read(Rails.root.join(
                  'spec',
                  'fixtures',
                  "dfe_sign_in_service_users_response_page_#{page}.json"
                ))
    end

    def stub_api_response_for_page(page)
      stub_request(:get,
                   "#{DFE_SIGN_IN_URL}/users?page=#{page}&pageSize=25")
        .to_return(body: response_file(page))
    end
  end
end
