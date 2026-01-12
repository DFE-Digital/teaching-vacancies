require "rails_helper"

RSpec.describe "Publishers can add a manual reference" do
  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:job_application) do
    create(:job_application, :status_interviewing,
           notes: build_list(:note, 1),
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let(:vacancy) { create(:vacancy, :expired, organisations: [school], publisher: publisher) }
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }
  let(:created_referee) { Referee.order(:created_at).last }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_ats_pre_interview_checks_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    click_on "Add a referee"
  end

  after { logout }

  it "errors nicely" do
    click_on "Save reference"
    expect(page).to have_content "There is a problem"
  end

  context "with referee details" do
    let(:referee_attrs) { attributes_for(:referee, is_most_recent_employer: false) }
    let(:referee_fillin) do
      {
        name: "Referee name",
        job_title: "Referee job title",
        relationship: "Referee relationship to applicant",
        email: "Referee email address",
        phone_number: "Referee phone number",
        organisation: "Referee organisation",
      }
    end

    before do
      choose "Referee details"
    end

    it "allows the publisher to add referee details" do
      referee_fillin.each do |k, v|
        fill_in v, with: referee_attrs.fetch(k)
      end

      click_on "Save reference"
      expect(page).to have_current_path(pre_interview_checks_organisation_job_job_application_path(vacancy.id, job_application.id))
      expect(created_referee.attributes
                            .symbolize_keys.except(:created_at, :updated_at, :email_ciphertext, :id,
                                                   :name_ciphertext, :job_application_id, :organisation_ciphertext,
                                                   :job_title_ciphertext, :phone_number_ciphertext)).to eq(referee_attrs)
      expect(ReferenceRequest.last.referee).to eq(created_referee)
    end
  end

  context "with uploaded reference", :js, :versioning do
    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(instance_double(Publishers::DocumentVirusCheck, safe?: true))
      choose "Upload a reference"
    end

    let(:referee_name) { Faker::Name.name }

    it "allows the publisher to add referee details" do
      fill_in "Referee name", with: referee_name

      page.attach_file("publishers-vacancies-job-applications-referee-form-reference-document-field", Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))
      click_on "Save reference"
      expect(page).to have_current_path(pre_interview_checks_organisation_job_job_application_path(vacancy.id, job_application.id))
      expect(created_referee.name).to eq(referee_name)
      expect(ReferenceRequest.last.slice(:marked_as_complete, :status).symbolize_keys).to eq(marked_as_complete: true, status: "received_off_service")
    end
  end
end
