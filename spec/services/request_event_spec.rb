require "rails_helper"

RSpec.describe RequestEvent do
  subject do
    described_class.new(
      request,
      response,
      session,
      jobseeker,
      current_publisher_oid,
    )
  end

  let(:request) do
    instance_double(
      ActionDispatch::Request,
      headers: { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)" },
      uuid: "00000000-0000-0000-0000-000000000000",
      remote_ip: "255.255.255.255",
      referer: "ukonline.gov.uk",
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

  let(:current_publisher_oid) { 1234 }
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
        request_uuid: "00000000-0000-0000-0000-000000000000",
        request_ip: "255.255.255.255",
        request_user_agent: "Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)",
        request_referer: "ukonline.gov.uk",
        request_method: "DELETE",
        request_path: "/foo/bar",
        request_query: "foo=bar&baz=bat",
        request_ab_tests: [{ test: :foo, variant: :bar }],
        response_content_type: "image/gif",
        response_status: 418,
        user_anonymised_request_identifier: "xeben-tocep-fadin-tezyg-rapic-begyn-hiraz-pedus-revuk-fisif-lypeh-tohim-lefyb-zolon-nilyk-sigud-coxux",
        user_anonymised_session_id: "xiler-ciziv-gytol-bivib-mycam-byvyp-linek-musoh-hutud-cosyc-bubul-kolat-kenyt-dumiz-gikin-zylip-poxex",
        user_anonymised_jobseeker_id: "xuzid-hugyr-gapol-dezon-lizab-hakog-lyvoh-ryson-soded-roher-nipal-zodes-kypiz-fygob-tynit-bifys-fyxex",
        user_anonymised_publisher_id: "xebop-senag-dehuz-fomah-satuc-vimep-humih-hesik-lyhyf-kimus-mesym-matyg-helyc-fevol-mihis-mocoz-gaxox",
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
