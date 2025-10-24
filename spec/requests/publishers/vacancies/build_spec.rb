require "rails_helper"

RSpec.describe "Job applications build" do
  let(:publisher) { create(:publisher, organisations: [trust]) }
  let(:trust) { build(:trust, schools: [school_one, school_two, school_three, school_four, school_without_phase]) }
  let(:school_one) { build(:school, phase: "nursery") }
  let(:school_two) { build(:school, phase: "secondary") }
  let(:school_three) { build(:school, phase: "sixth_form_or_college") }
  let(:school_four) { build(:school, phase: "secondary") }
  let(:school_without_phase) { build(:school, phase: "not_applicable") }

  before do
    sign_in(publisher, scope: :publisher)
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(trust)
  end

  after { sign_out(publisher) }

  describe "PATCH #update" do
    context "when the vacancy has been published" do
      context "when dependent steps have been made invalid" do
        context "when changing the job location" do
          let(:vacancy) { create(:vacancy, phases: ["nursery"], organisations: [school_one]) }

          before do
            allow(vacancy).to receive(:allow_key_stages?).and_return(true)
            patch(organisation_job_build_path(vacancy.id, :job_location, params))
          end

          context "when the job location is in a new phase" do
            let(:params) { { publishers_job_listing_job_location_form: { organisation_ids: [school_two.id] } } }

            it "redirects to the key_stages step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :key_stages))
            end
          end

          context "when updating the job location to be at multiple locations" do
            context "when neither of the locations' education phases share key stages with the vacancy's key stages" do
              let(:params) { { publishers_job_listing_job_location_form: { organisation_ids: [school_three.id, school_four.id] } } }

              it "redirects to the key_stages step" do
                expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :key_stages))
              end
            end
          end

          context "when updating the job location to be at the trust's head office" do
            let(:params) { { publishers_job_listing_job_location_form: { organisation_ids: [trust.id] } } }

            it "redirects to the education_phases step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :education_phases))
            end
          end
        end

        context "when changing the job role" do
          before { patch(organisation_job_build_path(vacancy.id, :job_role, params)) }

          context "when the new job_role can be ect_suitable" do
            let(:vacancy) { create(:vacancy, job_roles: ["headteacher"], organisations: [school_one]) }
            let(:params) { { publishers_job_listing_job_role_form: { job_roles: ["teacher"] } } }

            it "redirects to the about_the_role step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :about_the_role))
            end
          end

          context "when the the education_phase and the new job_role allows key_stages to be set" do
            let(:vacancy) { create(:vacancy, phases: %w[primary], job_roles: ["sendco"], organisations: [school_one]) }
            let(:params) { { publishers_job_listing_job_role_form: { job_roles: ["teacher"] } } }

            it "redirects to the key_stages step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :key_stages))
            end
          end
        end

        context "when changing the education_phase" do
          let(:vacancy) { create(:vacancy, phases: ["nursery"], organisations: [school_without_phase]) }

          before { patch(organisation_job_build_path(vacancy.id, :education_phases, params)) }

          context "when the vacancy's key_stages are not relevant to the new education phases" do
            let(:params) { { publishers_job_listing_education_phases_form: { phases: ["secondary"] } } }

            it "redirects to the key_stages step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :key_stages))
            end
          end
        end

        context "when changing receive_applications" do
          before { patch(organisation_job_build_path(vacancy.id, :how_to_receive_applications, params)) }

          context "when changing to uploaded_form" do
            let(:vacancy) { create(:vacancy, enable_job_applications: false, receive_applications: "website", organisations: [school_one]) }
            let(:params) { { publishers_job_listing_how_to_receive_applications_form: { receive_applications: "uploaded_form" } } }

            it "redirects to the application_form step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :application_form))
            end
          end

          context "when changing to website" do
            let(:vacancy) { create(:vacancy, enable_job_applications: false, receive_applications: "email", organisations: [school_one]) }
            let(:params) { { publishers_job_listing_how_to_receive_applications_form: { receive_applications: "website" } } }

            it "redirects to the application_link step" do
              expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :application_link))
            end
          end
        end

        context "when changing include_additional_documents to true" do
          before { patch(organisation_job_build_path(vacancy.id, :include_additional_documents, params)) }

          let(:vacancy) { create(:vacancy, include_additional_documents: false, organisations: [school_one]) }
          let(:params) { { publishers_job_listing_include_additional_documents_form: { include_additional_documents: true } } }

          it "redirects to the documents step" do
            expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :documents))
          end
        end
      end
    end

    context "when the vacancy is a draft" do
      context "when clicking save and finish later and there are invalid steps" do
        let(:further_details_provided) { nil }
        let(:further_details) { nil }
        let(:vacancy) { create(:draft_vacancy, organisations: [school_one], further_details_provided: nil, further_details: nil) }
        let(:params) { { publishers_job_listing_contact_details_form: { contact_email: Faker::Internet.email(domain: "contoso.com"), contact_number_provided: "true", contact_number: "07789123123" }, save_and_finish_later: "true" } }

        before { patch(organisation_job_build_path(vacancy.id, :contact_details, params: params)) }

        it "redirects to the show page" do
          expect(response).to redirect_to(organisation_job_path(vacancy.id))
        end
      end

      context "when all steps are valid" do
        let(:vacancy) { create(:draft_vacancy, include_additional_documents: nil, organisations: [school_one]) }
        let(:params) { { publishers_job_listing_include_additional_documents_form: { include_additional_documents: "false" } } }

        before { patch(organisation_job_build_path(vacancy.id, :include_additional_documents, params: params)) }

        it "redirects to the review page" do
          expect(response).to redirect_to(organisation_job_review_path(vacancy.id))
        end
      end

      context "when there are invalid steps" do
        let(:vacancy) { create(:draft_vacancy, further_details_provided: nil, further_details: nil, organisations: [school_one]) }
        let(:params) { { publishers_job_listing_contact_details_form: { contact_email: publisher.email, contact_number_provided: "true", contact_number: "07789123123" } } }

        before { patch(organisation_job_build_path(vacancy.id, :contact_details, params: params)) }

        it "redirects to the next invalid step" do
          expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :about_the_role))
        end
      end
    end
  end
end
