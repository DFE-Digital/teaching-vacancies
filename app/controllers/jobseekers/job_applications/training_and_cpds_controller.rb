module Jobseekers
  class JobApplications::TrainingAndCpdsController < BaseController
    before_action :set_job_application, only: %i[create edit new update destroy]
    before_action :set_training_and_cpd, only: %i[edit update destroy]

    def new
      @training_and_cpd = @job_application.training_and_cpds.build
    end

    def edit; end

    def create
      @training_and_cpd = @job_application.training_and_cpds.build(training_and_cpd_form_params)
      if @training_and_cpd.save
        redirect_to back_path
      else
        render :new
      end
    end

    def update
      if @training_and_cpd.update(training_and_cpd_form_params)
        redirect_to back_path
      else
        render :edit
      end
    end

    def destroy
      @training_and_cpd.destroy!
      redirect_to back_path, success: t(".success")
    end

    private

    def training_and_cpd_form_params
      params.expect(jobseekers_training_and_cpd_form: %i[name provider grade year_awarded course_length])
    end

    def set_training_and_cpd
      @training_and_cpd = @job_application.training_and_cpds.find(params[:id])
    end

    def set_job_application
      @job_application = current_jobseeker.job_applications.draft.find(params[:job_application_id])
    end

    def back_path
      @back_path ||= jobseekers_job_application_build_path(@job_application, :training_and_cpds)
    end
  end
end
