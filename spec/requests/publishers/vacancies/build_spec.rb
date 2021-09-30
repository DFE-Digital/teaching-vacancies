require "rails_helper"

RSpec.describe "Publishers::Vacancies::BuildController" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust) }
  let(:school1) { create(:school, name: "First school") }
  let(:school2) { create(:school, name: "Second school") }
  let(:vacancy) { create(:vacancy, :at_one_school, :draft, postcode_from_mean_geolocation: "Old postcode", organisation_vacancies_attributes: [{ organisation: school1 }]) }

  before do
    SchoolGroupMembership.find_or_create_by(school_id: school1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school2.id, school_group_id: school_group.id)
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(school_group)
    sign_in(publisher, scope: :publisher)
  end

  describe "PATCH #update" do
    context "when updating which organisations a vacancy is associated to" do
      before do
        # set session[:job_location]
        patch organisation_job_build_path(vacancy.id, :job_location), params: {
          publishers_job_listing_job_location_form: { job_location: "at_multiple_schools" },
        }
      end

      it "updates the vacancy's postcode_from_mean_geolocation attribute" do
        expect {
          patch organisation_job_build_path(vacancy.id, :schools), params: {
            publishers_job_listing_schools_form: { organisation_ids: [school1.id, school2.id] },
          }
        }.to change { vacancy.reload.postcode_from_mean_geolocation }.to(Geocoder::DEFAULT_LOCATION)
      end
    end
  end
end
