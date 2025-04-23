require "rails_helper"

RSpec.describe "Accessing an organisation profile" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    sign_in(publisher, scope: :publisher)
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation) # rubocop:disable RSpec/AnyInstance
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when the publisher current organisation is a school" do
      let(:organisation) { create(:school) }

      it "can access the school profile by their friendly_id" do
        get publishers_organisation_path(organisation.friendly_id)
        expect(response).to render_template(:show)
      end

      it "can access the school profile by their id" do
        get publishers_organisation_path(organisation.id)
        expect(response).to render_template(:show)
      end

      it "shows a 404 page when the given school id does not exist" do
        get publishers_organisation_path("non-existent")
        expect(response).to have_http_status(:not_found)
        expect(response).to render_template("errors/not_found")
      end

      it "shows a 404 page when the given school id is not the current publisher organisation" do
        another_school = create(:school)
        get publishers_organisation_path(another_school.friendly_id)
        expect(response).to have_http_status(:not_found)
        expect(response).to render_template("errors/not_found")
      end
    end

    context "when the publisher current organisation is a school group" do
      let(:organisation) { create(:school_group) }
      let(:school) { create(:school) }

      before { organisation.schools << school }

      it "can access the school group profile by their friendly_id" do
        get publishers_organisation_path(organisation.friendly_id)
        expect(response).to render_template(:show)
      end

      it "can access the school group profile by their id" do
        get publishers_organisation_path(organisation.id)
        expect(response).to render_template(:show)
      end

      it "can access an organisation school's profile by their friendly_id" do
        get publishers_organisation_path(school.friendly_id)
        expect(response).to render_template(:show)
      end

      it "can access an organisation school's profile by their id" do
        get publishers_organisation_path(school.id)
        expect(response).to render_template(:show)
      end

      it "shows a 404 page when the given school id does not exist" do
        get publishers_organisation_path("non-existent")
        expect(response).to have_http_status(:not_found)
        expect(response).to render_template("errors/not_found")
      end

      it "shows a 404 page when the given school does not belong to the school group" do
        another_school = create(:school)
        get publishers_organisation_path(another_school.friendly_id)
        expect(response).to have_http_status(:not_found)
        expect(response).to render_template("errors/not_found")
      end
    end
  end
end
