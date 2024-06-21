require "rails_helper"

module Vacancies::Export::DwpFindAJob::PublishedAndUpdatedVacancies
  RSpec.describe Xml do
    describe "#xml" do
      let(:vacancy) { instance_double(Vacancy, organisation: org) }
      let(:org) do
        build_stubbed(:school,
                      address: "1 School Lane",
                      town: "School Town",
                      county: "School County",
                      postcode: "AB12 3CD")
      end
      let(:parsed_vacancy) do
        instance_double(
          ParsedVacancy,
          id: "10",
          organisation: org,
          job_title: "Awesome teacher",
          description: "Job description",
          expiry: "2024-10-04",
          type_id: ParsedVacancy::TYPE_PERMANENT_ID,
          category_id: ParsedVacancy::CATEGORY_EDUCATION_ID,
          status_id: ParsedVacancy::STATUS_FULL_TIME_ID,
          apply_url: "http://www.example.com/jobs/awesome-teacher",
        )
      end

      subject { described_class.new([vacancy]) }

      it "generates an XML document with the given vacancies data parsed for DWP Find a Job service" do
        expect(ParsedVacancy).to receive(:new).with(vacancy).and_return(parsed_vacancy)
        expect(subject.xml).to eq(
          <<~XML,
            <?xml version="1.0" encoding="UTF-8"?>
            <Vacancies>
              <Vacancy vacancyRefCode="10">
                <Title>Awesome teacher</Title>
                <Description>Job description</Description>
                <Location>
                  <StreetAddress>1 School Lane</StreetAddress>
                  <City>School Town</City>
                  <State>School County</State>
                  <PostalCode>AB12 3CD</PostalCode>
                </Location>
                <VacancyExpiry>2024-10-04</VacancyExpiry>
                <VacancyType id="#{ParsedVacancy::TYPE_PERMANENT_ID}"/>
                <VacancyStatus id="#{ParsedVacancy::STATUS_FULL_TIME_ID}"/>
                <VacancyCategory id="#{ParsedVacancy::CATEGORY_EDUCATION_ID}"/>
                <ApplyMethod id="#{Xml::APPLY_VIA_EXTERNAL_URL_ID}"/>
                <ApplyUrl>http://www.example.com/jobs/awesome-teacher</ApplyUrl>
              </Vacancy>
            </Vacancies>
          XML
        )
      end

      it "ommits the expiry information if the parsed vacancy doesn't have an expiry date" do
        allow(parsed_vacancy).to receive(:expiry).and_return(nil)
        expect(ParsedVacancy).to receive(:new).with(vacancy).and_return(parsed_vacancy)

        expect(subject.xml).to eq(
          <<~XML,
            <?xml version="1.0" encoding="UTF-8"?>
            <Vacancies>
              <Vacancy vacancyRefCode="10">
                <Title>Awesome teacher</Title>
                <Description>Job description</Description>
                <Location>
                  <StreetAddress>1 School Lane</StreetAddress>
                  <City>School Town</City>
                  <State>School County</State>
                  <PostalCode>AB12 3CD</PostalCode>
                </Location>
                <VacancyType id="#{ParsedVacancy::TYPE_PERMANENT_ID}"/>
                <VacancyStatus id="#{ParsedVacancy::STATUS_FULL_TIME_ID}"/>
                <VacancyCategory id="#{ParsedVacancy::CATEGORY_EDUCATION_ID}"/>
                <ApplyMethod id="#{Xml::APPLY_VIA_EXTERNAL_URL_ID}"/>
                <ApplyUrl>http://www.example.com/jobs/awesome-teacher</ApplyUrl>
              </Vacancy>
            </Vacancies>
        XML
        )
      end

      describe "location data generation" do
        context "when the vacancy organisation has only the postcode from the address" do
          let(:org) { build_stubbed(:school, address: nil, town: nil, county: nil, postcode: "AB12 3CD") }

          it "generates an XML document omitting the missing location data" do
            expect(ParsedVacancy).to receive(:new).with(vacancy).and_return(parsed_vacancy)
            expect(subject.xml).to eq(
              <<~XML,
                <?xml version="1.0" encoding="UTF-8"?>
                <Vacancies>
                  <Vacancy vacancyRefCode="10">
                    <Title>Awesome teacher</Title>
                    <Description>Job description</Description>
                    <Location>
                      <PostalCode>AB12 3CD</PostalCode>
                    </Location>
                    <VacancyExpiry>2024-10-04</VacancyExpiry>
                    <VacancyType id="#{ParsedVacancy::TYPE_PERMANENT_ID}"/>
                    <VacancyStatus id="#{ParsedVacancy::STATUS_FULL_TIME_ID}"/>
                    <VacancyCategory id="#{ParsedVacancy::CATEGORY_EDUCATION_ID}"/>
                    <ApplyMethod id="#{Xml::APPLY_VIA_EXTERNAL_URL_ID}"/>
                    <ApplyUrl>http://www.example.com/jobs/awesome-teacher</ApplyUrl>
                  </Vacancy>
                </Vacancies>
            XML
            )
          end

          context "when the vacancy organisation doesn't include the mandatory postcode" do
            let(:org) { build_stubbed(:school, address: "Address", town: "Town", county: "County", postcode: nil) }

            it "the xml document does not include the vacancy" do
              expect(subject.xml).to eq(
                <<~XML,
                  <?xml version="1.0" encoding="UTF-8"?>
                  <Vacancies/>
              XML
              )
            end
          end

          context "when there are no vacancies" do
            subject { described_class.new([]) }

            it "returns nil" do
              expect(subject.xml).to be_nil
            end
          end
        end
      end

      context "when there are multiple vacancies" do
        let(:vacancy2) { instance_double(Vacancy, organisation: org) }
        let(:parsed_vacancy2) do
          instance_double(
            ParsedVacancy,
            id: "11",
            organisation: org,
            job_title: "Another teacher",
            description: "Another job description",
            expiry: "2024-10-04",
            type_id: ParsedVacancy::TYPE_CONTRACT_ID,
            category_id: ParsedVacancy::CATEGORY_EDUCATION_ID,
            status_id: ParsedVacancy::STATUS_PART_TIME_ID,
            apply_url: "http://www.example.com/jobs/another-teacher",
          )
        end

        subject { described_class.new([vacancy, vacancy2]) }

        it "generates an XML document with all given vacancies data parsed for DWP Find a Job service" do
          expect(ParsedVacancy).to receive(:new).with(vacancy).and_return(parsed_vacancy)
          expect(ParsedVacancy).to receive(:new).with(vacancy2).and_return(parsed_vacancy2)

          expect(subject.xml).to eq(
            <<~XML,
              <?xml version="1.0" encoding="UTF-8"?>
              <Vacancies>
                <Vacancy vacancyRefCode="10">
                  <Title>Awesome teacher</Title>
                  <Description>Job description</Description>
                  <Location>
                    <StreetAddress>1 School Lane</StreetAddress>
                    <City>School Town</City>
                    <State>School County</State>
                    <PostalCode>AB12 3CD</PostalCode>
                  </Location>
                  <VacancyExpiry>2024-10-04</VacancyExpiry>
                  <VacancyType id="#{ParsedVacancy::TYPE_PERMANENT_ID}"/>
                  <VacancyStatus id="#{ParsedVacancy::STATUS_FULL_TIME_ID}"/>
                  <VacancyCategory id="#{ParsedVacancy::CATEGORY_EDUCATION_ID}"/>
                  <ApplyMethod id="#{Xml::APPLY_VIA_EXTERNAL_URL_ID}"/>
                  <ApplyUrl>http://www.example.com/jobs/awesome-teacher</ApplyUrl>
                </Vacancy>
                <Vacancy vacancyRefCode="11">
                  <Title>Another teacher</Title>
                  <Description>Another job description</Description>
                  <Location>
                    <StreetAddress>1 School Lane</StreetAddress>
                    <City>School Town</City>
                    <State>School County</State>
                    <PostalCode>AB12 3CD</PostalCode>
                  </Location>
                  <VacancyExpiry>2024-10-04</VacancyExpiry>
                  <VacancyType id="#{ParsedVacancy::TYPE_CONTRACT_ID}"/>
                  <VacancyStatus id="#{ParsedVacancy::STATUS_PART_TIME_ID}"/>
                  <VacancyCategory id="#{ParsedVacancy::CATEGORY_EDUCATION_ID}"/>
                  <ApplyMethod id="#{Xml::APPLY_VIA_EXTERNAL_URL_ID}"/>
                  <ApplyUrl>http://www.example.com/jobs/another-teacher</ApplyUrl>
                </Vacancy>
              </Vacancies>
          XML
          )
        end
      end
    end
  end
end
