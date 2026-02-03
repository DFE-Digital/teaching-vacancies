require "rails_helper"

RSpec.describe Publisher do
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:publisher_preferences) }
  it { is_expected.to have_many(:emergency_login_keys) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:notifications) }

  describe "#vacancies_with_job_applications_submitted_yesterday" do
    let!(:publisher) { create(:publisher) }
    let!(:vacancy1) { create(:vacancy, publisher: publisher) }
    let!(:vacancy2) { create(:vacancy, publisher: publisher) }
    let!(:job_application1) { create(:job_application, :status_submitted, vacancy: vacancy1, submitted_at: 1.day.ago) }
    let!(:job_application2) { create(:job_application, :status_submitted, vacancy: vacancy2, submitted_at: 2.days.ago) }

    it "returns vacancies with job applications submitted yesterday" do
      expect(publisher.vacancies_with_job_applications_submitted_yesterday).to eq [vacancy1]
    end
  end

  describe "#accessible_organisations" do
    subject(:accessible_organisations) { publisher.accessible_organisations(current_organisation) }

    let(:publisher) { create(:publisher) }
    let(:school) { create(:school) }

    let(:current_organisation) { school }

    context "when no current organisation is given" do
      let(:current_organisation) { nil }

      it "returns an empty collection" do
        expect(accessible_organisations).to eq []
      end
    end

    context "when the current organisation is a School" do
      let(:current_organisation) { school }

      context "when the publisher has preferences for the School" do
        # School preferences if present are empty from orgs as they're created empty by Publishers::VacanciesController#index
        let!(:publisher_preference) do
          create(:publisher_preference, publisher: publisher, organisation: current_organisation, organisations: [])
        end

        it "returns the school" do
          expect(accessible_organisations).to eq [school]
        end
      end

      context "when the publisher has no preferences for the School" do
        let(:different_organisation) { create(:school) }
        let!(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: different_organisation) }

        it "returns the school" do
          expect(accessible_organisations).to eq [school]
        end
      end
    end

    context "when the current organisation is a local authority" do
      let(:la_first_school) { create(:school) }
      let(:la_second_school) { create(:school) }
      let(:local_authority) { create(:local_authority, schools: [la_first_school, la_second_school]) }
      let(:current_organisation) { local_authority }

      context "when the publisher has preferences with schools for the local authority" do
        let!(:publisher_preference) do
          create(:publisher_preference, publisher: publisher, organisation: current_organisation, schools: [la_second_school], organisations: [])
        end

        it "returns the schools from its preferences" do
          expect(accessible_organisations).to eq [la_second_school]
        end
      end

      context "when the publisher has preferences without schools or organisations for the local authority" do
        let!(:publisher_preference) do
          create(:publisher_preference, publisher: publisher, organisation: current_organisation, organisations: [], schools: [])
        end

        it "returns an empty collection" do
          expect(accessible_organisations).to eq []
        end
      end

      context "when the publisher has no preferences for the local authority" do
        let(:different_organisation) { create(:school) }
        let!(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: different_organisation) }

        it "returns the local authority and all its schools" do
          expect(accessible_organisations).to contain_exactly(local_authority, la_first_school, la_second_school)
        end
      end
    end

    context "when the current organisation is a trust" do
      let(:trust_first_school) { create(:school) }
      let(:trust_second_school) { create(:school) }
      let(:trust) { create(:trust, schools: [trust_first_school, trust_second_school]) }
      let(:current_organisation) { trust }

      context "when the publisher has preferences with schools for the trust" do
        let!(:publisher_preference) do
          create(:publisher_preference, publisher: publisher, organisation: current_organisation, schools: [trust_second_school], organisations: [])
        end

        it "ignores the preferences and returns the trust and all its schools" do
          expect(accessible_organisations).to contain_exactly(trust, trust_first_school, trust_second_school)
        end
      end

      context "when the publisher has preferences without schools or organisations for the trust" do
        let!(:publisher_preference) do
          create(:publisher_preference, publisher: publisher, organisation: current_organisation, organisations: [], schools: [])
        end

        it "returns the trust and all its schools" do
          expect(accessible_organisations).to contain_exactly(trust, trust_first_school, trust_second_school)
        end
      end

      context "when the publisher has no preferences for the trust" do
        let(:different_organisation) { create(:school) }
        let!(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: different_organisation) }

        it "returns the trust and all its schools" do
          expect(accessible_organisations).to contain_exactly(trust, trust_first_school, trust_second_school)
        end
      end
    end
  end
end
