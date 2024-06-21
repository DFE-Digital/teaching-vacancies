require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies::Xml do
  describe "#xml" do
    let(:vacancy1) { instance_double(Vacancy, id: 1) }
    let(:vacancy2) { instance_double(Vacancy, id: 2) }

    subject { described_class.new([vacancy1, vacancy2]) }

    it "generates an XML document with the given vacancy references to be deleted" do
      expect(subject.xml).to eq(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8"?>
          <ExpireVacancies>
            <ExpireVacancy vacancyRefCode="1"/>
            <ExpireVacancy vacancyRefCode="2"/>
          </ExpireVacancies>
        XML
      )
    end

    context "when there are no vacancies to be deleted" do
      subject { described_class.new([]) }

      it "returns nil" do
        expect(subject.xml).to be_nil
      end
    end
  end
end
