module Jobseekers
  class JobApplications::ProfessionalBodyMembershipsController < BaseController
    before_action :set_job_application, only: %i[create edit new update destroy]

    before_action :set_model, only: %i[edit update destroy]

    def new
      @model = @job_application.professional_body_memberships.build
    end

    def edit; end

    def create
      @model = @job_application.professional_body_memberships.build(professional_body_memberships_form_params)

      if @model.save
        redirect_to back_path
      else
        render :new
      end
    end

    def update
      if @model.update(professional_body_memberships_form_params)
        redirect_to back_path
      else
        render :edit
      end
    end

    def destroy
      @model.destroy!
      redirect_to back_path, success: t(".success")
    end

    private

    def professional_body_memberships_form_params
      params.expect(jobseekers_professional_body_membership_form: %i[name membership_type membership_number year_membership_obtained exam_taken])
    end

    def set_model
      @model = @job_application.professional_body_memberships.find(params[:id])
    end

    def set_job_application
      @job_application = current_jobseeker.job_applications.draft.find(params[:job_application_id])
    end

    def back_path
      @back_path ||= jobseekers_job_application_build_path(@job_application, :professional_body_memberships)
    end
  end
end
