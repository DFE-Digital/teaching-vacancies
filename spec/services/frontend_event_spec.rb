require "rails_helper"

RSpec.describe FrontendEvent do
  subject do
    described_class.new(request, response, session, jobseeker, publisher)
  end

  let(:request) do
    instance_double(
      ActionDispatch::Request,
      headers: { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)" },
      uuid: "00000000-0000-0000-0000-000000000000",
      remote_ip: "255.255.255.255",
      referer: "https://tv.gov.uk/blah-di?blub",
      method: "DELETE",
      path: "/foo/bar",
      query_string: "foo=bar&baz=bat",
    )
  end

  let(:response) do
    instance_double(ActionDispatch::Response, content_type: "image/gif", status: 418)
  end

  let(:session) do
    instance_double(ActionDispatch::Request::Session, id: "1337")
  end

  let(:publisher) { instance_double(Publisher, oid: 1234) }
  let(:jobseeker) { instance_double(Jobseeker, id: 4321) }

  let(:ab_tests) { double(AbTests, current_variants: { foo: :bar }) }

  before do
    allow(AbTests).to receive(:new).with(session).and_return(ab_tests)
  end

  describe "#trigger" do
    let(:expected_data) do
      {
        type: :reticulated_splines,
        occurred_at: "1999-12-31T23:59:59.000000Z",
        request_uuid: nil,
        request_user_agent: "Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)",
        request_referer: nil,
        request_method: nil,
        request_path: "/blah-di",
        request_query: "blub",
        request_ab_tests: [{ test: :foo, variant: :bar }],
        response_content_type: nil,
        response_status: nil,
        user_anonymised_request_identifier: anonymised_form_of("Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)255.255.255.255"),
        user_anonymised_session_id: anonymised_form_of("1337"),
        user_anonymised_jobseeker_id: anonymised_form_of("4321"),
        user_anonymised_publisher_id: anonymised_form_of("1234"),
        data: [{ key: "foo", value: "Bar" }],
      }
    end

    it "enqueues a SendEventToDataWarehouseJob with the expected payload" do
      expect(SendEventToDataWarehouseJob).to receive(:perform_later).with("events", expected_data)

      travel_to(Time.zone.local(1999, 12, 31, 23, 59, 59)) do
        subject.trigger(:reticulated_splines, foo: "Bar")
      end
    end
  end
end
