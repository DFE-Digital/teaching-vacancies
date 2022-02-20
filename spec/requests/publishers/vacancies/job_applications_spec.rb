require "rails_helper"

RSpec.describe "Job applications" do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "GET #reject" do
    context "when the job application status is not draft or withdrawn" do
      it "renders the reject page" do
        expect(get(organisation_job_job_application_reject_path(vacancy.id, job_application.id)))
          .to render_template(:reject)
      end
    end

    context "when the job application status is draft" do
      let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_reject_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot reject/)
      end
    end

    context "when the job application status is withdrawn" do
      let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_reject_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot reject/)
      end
    end
  end

  describe "GET #shortlist" do
    context "when the job application status is not draft or withdrawn" do
      it "renders the show page" do
        expect(get(organisation_job_job_application_shortlist_path(vacancy.id, job_application.id)))
          .to render_template(:shortlist)
      end
    end

    context "when the job application status is draft" do
      let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_shortlist_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot shortlist/)
      end
    end

    context "when the job application status is withdrawn" do
      let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_shortlist_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot shortlist/)
      end
    end
  end

  describe "GET #show" do
    context "when the job application status is not draft or withdrawn" do
      it "renders the show page" do
        expect(get(organisation_job_job_application_path(vacancy.id, job_application.id))).to render_template(:show)
      end
    end

    context "when the job application status is submitted" do
      it "updates the job application status to reviewed" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to change { job_application.reload.status }.from("submitted").to("reviewed")
      end
    end

    context "when the job application status is not submitted" do
      let(:job_application) { create(:job_application, :status_shortlisted, vacancy: vacancy) }

      it "does not update the job application status" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to(not_change { job_application.reload.status })
      end
    end

    context "when the job application status is draft" do
      let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot view/)
      end
    end

    context "when the job application status is withdrawn" do
      let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

      it "redirects to the withdrawn page" do
        expect(get(organisation_job_job_application_path(vacancy.id, job_application.id)))
          .to redirect_to(organisation_job_job_application_withdrawn_path(vacancy.id, job_application.id))
      end
    end
  end

  describe "GET #index" do
    context "when the vacancy does not belong to the current organisation" do
      let(:vacancy) { create(:vacancy, :published, organisations: [build(:school)]) }

      it "returns not_found" do
        get organisation_job_job_applications_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not listed" do
      let(:vacancy) { create(:vacancy, publish_on: 1.day.from_now, organisations: [organisation]) }

      it "returns not_found" do
        get organisation_job_job_applications_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the index page" do
      expect(get(organisation_job_job_applications_path(vacancy.id))).to render_template(:index)
    end
  end

  describe "POST #update_status" do
    context "when the job application status is not draft or withdrawn" do
      context "when shortlisting a job application" do
        let(:params) { { publishers_job_application_update_status_form: { further_instructions: "do this" } } }

        it "updates the status" do
          expect { post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params) }
            .to change { job_application.reload.status }.from("submitted").to("shortlisted")
        end

        it "sends an email" do
          assert_emails 1 do
            post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params)
          end
        end

        it "redirects to job applications page" do
          expect(post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params))
            .to redirect_to(organisation_job_job_applications_path(vacancy.id))
        end
      end

      context "when rejecting a job application" do
        let(:params) { { publishers_job_application_update_status_form: { rejection_reasons: "second choice" } } }

        it "updates the status" do
          expect { post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params) }
            .to change { job_application.reload.status }.from("submitted").to("unsuccessful")
        end

        it "sends an email" do
          assert_emails 1 do
            post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params)
          end
        end

        it "redirects to job applications page" do
          expect(post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params))
            .to redirect_to(organisation_job_job_applications_path(vacancy.id))
        end
      end
    end

    context "when the job application status is draft" do
      let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy) }
      let(:params) { { publishers_job_application_update_status_form: { rejection_reasons: "second choice" } } }

      it "raises an error" do
        expect { post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params) }
          .to raise_error(ActionController::RoutingError, /Cannot shortlist or reject/)
      end
    end

    context "when the job application status is withdrawn" do
      let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }
      let(:params) { { publishers_job_application_update_status_form: { rejection_reasons: "second choice" } } }

      it "raises an error" do
        expect { post(organisation_job_job_application_update_status_path(vacancy.id, job_application.id), params: params) }
          .to raise_error(ActionController::RoutingError, /Cannot shortlist or reject/)
      end
    end
  end
end
