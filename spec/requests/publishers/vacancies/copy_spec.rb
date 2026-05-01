# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::Vacancies::CopyController" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end
  # rubocop:enable RSpec/AnyInstance

  after { sign_out(publisher) }

  describe "POST #create" do
    let(:name) { Faker::CryptoCoin.coin_name }

    context "with a simple vacancy" do
      let(:vacancy) { create(:vacancy, :no_tv_applications, organisations: [organisation]) }

      it "copies a vacancy into a template" do
        expect {
          post organisation_job_copy_path(vacancy.id, params: { vacancy_template: { name: name } })
        }.to change(VacancyTemplate, :count).by(1)
      end
    end

    context "with a legacy email vacancy" do
      let(:vacancy) { create(:vacancy, :legacy_email_application, organisations: [organisation]) }

      it "copies a vacancy into a template" do
        expect {
          post organisation_job_copy_path(vacancy.id, params: { vacancy_template: { name: name } })
        }.to change(VacancyTemplate, :count).by(1)
        expect(VacancyTemplate.last).to have_attributes(name: name, receive_applications: nil)
      end
    end
  end
end
