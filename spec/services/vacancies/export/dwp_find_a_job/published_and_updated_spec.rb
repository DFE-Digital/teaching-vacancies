require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::PublishedAndUpdated do
  describe "#call" do
    subject { described_class.new("2024-05-01") }

    let(:org) do
      create(:school,
             address: "1 School Lane",
             town: "School Town",
             county: "School County",
             postcode: "AB12 3CD",
             safeguarding_information: "Safeguarding text")
    end
    let(:vacancy_published_old) do
      create(:vacancy,
             publish_on: 2.days.ago,
             created_at: 2.days.ago,
             updated_at: 2.days.ago,
             expires_at: 40.days.after)
    end
    let(:vacancy_published) do
      create(:vacancy,
             id: "ff7af59b-558b-4c55-9941-fe1942d84984",
             publish_on: 1.hour.ago,
             updated_at: 2.weeks.ago,
             created_at: 2.weeks.ago,
             job_title: "Great teacher",
             skills_and_experience: "We need a great teacher",
             school_offer: "<p>We are a <strong>great school</strong></p><ul><li>Item 0</li><li>Item 1<ul><li>Item A<ol><li>Item i</li><li>Item ii</li></ol></li><li>Item B<ul><li>Item i</li></ul></li></ul></li><li>Item 2</li></ul><p><a href='url'>link text</a>",
             further_details: "More details",
             expires_at: Time.zone.local(2024, 5, 17, 9, 0, 0),
             working_patterns: ["full_time"],
             job_roles: ["teacher"],
             contract_type: "permanent",
             slug: "great-teacher",
             organisations: [org])
    end
    let(:vacancy_updated) do
      create(:vacancy,
             id: "0ee558c1-3587-4f7a-a0c2-d40a2289c7fe",
             publish_on: 2.days.ago,
             updated_at: 1.hour.ago,
             created_at: 1.hour.ago,
             job_title: "IT technician",
             skills_and_experience: "We need a IT technician",
             school_offer: "We offer a great school",
             further_details: "More details",
             expires_at: Time.zone.local(2024, 5, 20, 9, 0, 0),
             working_patterns: ["part_time"],
             job_roles: ["it_support"],
             contract_type: "fixed_term",
             slug: "it-technician",
             organisations: [org])
    end
    let(:vacancy_to_be_reposted) do
      create(:vacancy,
             id: "51d379eb-78f8-47ab-be8e-307887d4c807",
             publish_on: 62.days.ago,
             updated_at: 62.days.ago,
             created_at: 62.days.ago,
             job_title: "Maths teacher",
             skills_and_experience: "We need a maths teacher",
             school_offer: "We offer a great school for a maths teacher",
             further_details: "More details",
             expires_at: Time.zone.local(2024, 5, 17, 9, 0, 0),
             working_patterns: ["full_time"],
             job_roles: ["teacher"],
             contract_type: "permanent",
             slug: "maths-teacher",
             organisations: [org])
    end

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:tempfile) { instance_double(Tempfile, path: "/tmp/#{filename}", flush: true, close!: true, write: true) }
    let(:filename) { "TeachingVacancies-upload-20240502-010444" }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
      vacancy_published_old
      vacancy_published
      vacancy_to_be_reposted
      vacancy_updated

      allow(Tempfile).to receive(:new).with(filename).and_return(tempfile)
      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    after do
      travel_back
    end

    it "generates an XML file with the vacancies published/edited after the given date" do
      subject.call

      written_content = nil
      expect(tempfile).to have_received(:write) do |content|
        written_content = content
      end

      doc = Nokogiri::XML(written_content)
      vacancies = doc.xpath("//Vacancy")

      expect(vacancies.count).to eq(3)

      ref_codes = vacancies.pluck("vacancyRefCode")
      expect(ref_codes).to contain_exactly(
        vacancy_published.id,
        "#{vacancy_to_be_reposted.id}-2",
        vacancy_updated.id,
      )

      great_teacher = vacancies.find { |v| v.xpath("Title").text == "Great teacher" }
      expect(great_teacher["vacancyRefCode"]).to eq(vacancy_published.id)
      expect(great_teacher.xpath("VacancyExpiry").text).to eq("2024-05-17")
      expect(great_teacher.xpath("VacancyType").first["id"]).to eq("1")
      expect(great_teacher.xpath("ApplyUrl").text).to eq("http://localhost:3000/jobs/great-teacher")

      maths_teacher = vacancies.find { |v| v.xpath("Title").text == "Maths teacher" }
      expect(maths_teacher["vacancyRefCode"]).to eq("#{vacancy_to_be_reposted.id}-2")
      expect(maths_teacher.xpath("VacancyExpiry").text).to eq("2024-05-17")

      it_technician = vacancies.find { |v| v.xpath("Title").text == "IT technician" }
      expect(it_technician["vacancyRefCode"]).to eq(vacancy_updated.id)
      expect(it_technician.xpath("VacancyExpiry").text).to eq("2024-05-20")
      expect(it_technician.xpath("VacancyType").first["id"]).to eq("2")
    end

    it "uploads the XML file to the SFTP server" do
      subject.call
      expect(sftp_session).to have_received(:upload!).with(%r{^/tmp/#{filename}}, "Inbound/#{filename}.xml")
    end

    it "logs the upload" do
      allow(Rails.logger).to receive(:info)

      subject.call
      expect(Rails.logger).to have_received(:info)
        .with("[DWP Find a Job] Uploaded '#{filename}.xml': Containing 3 vacancies to publish.")
    end
  end
end
