require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies::Xml do
  describe "#xml" do
    subject { described_class.new([vacancy1, vacancy2]) }

    let(:vacancy1) { instance_double(Vacancy, id: "ff7af59b-558b-4c55-9941-fe1942d84984", publish_on: 3.days.ago) }
    let(:vacancy2) { instance_double(Vacancy, id: "0ee558c1-3587-4f7a-a0c2-d40a2289c7fe", publish_on: 30.days.ago) }

    before { travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44)) }
    after { travel_back }

    it "generates an XML document with the given vacancy references to be deleted" do
      expect(subject.xml).to eq(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8"?>
          <ExpireVacancies>
            <ExpireVacancy vacancyRefCode="ff7af59b-558b-4c55-9941-fe1942d84984"/>
            <ExpireVacancy vacancyRefCode="0ee558c1-3587-4f7a-a0c2-d40a2289c7fe"/>
          </ExpireVacancies>
        XML
      )
    end

    context "when the vacancy that was closed early was published longer than 30 days ago" do
      before do
        allow(vacancy1).to receive(:publish_on).and_return(31.days.ago)
        allow(vacancy2).to receive(:publish_on).and_return(62.days.ago)
      end

      it "uses the appropriate version in of the advert reference" do
        expect(subject.xml).to eq(
          <<~XML,
            <?xml version="1.0" encoding="UTF-8"?>
            <ExpireVacancies>
              <ExpireVacancy vacancyRefCode="ff7af59b-558b-4c55-9941-fe1942d84984-1"/>
              <ExpireVacancy vacancyRefCode="0ee558c1-3587-4f7a-a0c2-d40a2289c7fe-2"/>
            </ExpireVacancies>
          XML
        )
      end
    end

    context "when there are no vacancies to be deleted" do
      subject { described_class.new([]) }

      it "returns nil" do
        expect(subject.xml).to be_nil
      end
    end
  end
end
