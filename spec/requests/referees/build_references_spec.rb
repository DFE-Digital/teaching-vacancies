# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Referees::BuildReferencesController" do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy, jobseeker: jobseeker) }
  let(:referee) { create(:referee, job_application: job_application) }
  let(:reference_request) { create(:reference_request, referee: referee, status: :requested) }
  let!(:job_reference) { create(:job_reference, reference_request: reference_request) }
  let(:token) { reference_request.token }

  describe "GET #show" do
    context "with an invalid token" do
      it "returns 404 not found" do
        get reference_build_path(reference_request.id, :can_give, token: "invalid-token")

        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an expired token (older than 12 weeks)" do
      before do
        reference_request.update!(created_at: 13.weeks.ago)
      end

      it "returns 404 not found" do
        get reference_build_path(reference_request.id, :can_give, token: token)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the job application is in a terminal state" do
      JobApplication::TERMINAL_STATUSES.each do |status|
        context "when status is #{status}" do
          before do
            # Use update_column to bypass state machine validations for testing
            job_application.update_column(:status, JobApplication.statuses[status])
          end

          it "renders the no_longer_available page" do
            get reference_build_path(reference_request.id, :can_give, token: token)

            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:no_longer_available)
            expect(response.body).to include("This reference request is no longer available")
            expect(response).not_to render_template(:can_give)
          end
        end
      end
    end

    context "when the job application is in an active state" do
      it "renders the can_give step normally" do
        get reference_build_path(reference_request.id, :can_give, token: token)

        expect(response).to render_template(:can_give)
        expect(response.body).to include("Provide a reference")
      end
    end
  end

  describe "PATCH #update" do
    context "with an invalid token" do
      it "returns 404 not found" do
        patch reference_build_path(reference_request.id, :can_give, token: "invalid-token"), params: {
          referees_can_give_reference_form: {
            can_give_reference: "true",
            token: "invalid-token",
          },
        }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the job application is in a terminal state" do
      JobApplication::TERMINAL_STATUSES.each do |status|
        context "when status is #{status}" do
          before do
            # Use update_column to bypass state machine validations for testing
            job_application.update_column(:status, JobApplication.statuses[status])
          end

          it "renders the no_longer_available page" do
            patch reference_build_path(reference_request.id, :can_give, token: token), params: {
              referees_can_give_reference_form: {
                can_give_reference: "true",
                token: token,
              },
            }

            expect(response).to render_template(:no_longer_available)
          end

          it "does not update the reference" do
            expect {
              patch reference_build_path(reference_request.id, :can_give, token: token), params: {
                referees_can_give_reference_form: {
                  can_give_reference: "true",
                  token: token,
                },
              }
            }.not_to(change { job_reference.reload.can_give_reference })
          end
        end
      end
    end

    context "when the job application is in an active state" do
      it "processes the form update normally" do
        patch reference_build_path(reference_request.id, :can_give, token: token), params: {
          referees_can_give_reference_form: {
            can_give_reference: "true",
            token: token,
          },
        }

        expect(response).to have_http_status(:redirect)
        expect(job_reference.reload.can_give_reference).to be(true)
      end
    end
  end
end
