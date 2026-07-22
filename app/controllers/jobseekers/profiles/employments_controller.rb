module Jobseekers
  class Profiles::EmploymentsController < ProfilesController
    before_action :set_employment, only: %i[edit update destroy]

    def new
      @employment = @profile.employment_jobs.build
    end

    def edit; end

    def create
      @employment = @profile.employment_jobs.build

      if @employment.update(employment_form_params)
        redirect_to review_jobseekers_profile_work_history_index_path
      else
        render :new
      end
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      e.errors.each do |error|
        @employment.errors.add(error.attribute, :invalid)
      end
      render :new
    end

    def update
      if @employment.update(employment_form_params)
        redirect_to review_jobseekers_profile_work_history_index_path, success: t(".success")
      else
        render :edit
      end
    end

    def destroy
      @employment.destroy

      redirect_to review_jobseekers_profile_work_history_index_path, success: t(".success")
    end

    def review
      @employments = @profile.employments.order(:ended_on)
    end

    private

    def set_employment
      @employment = @profile.employments.find(params[:id])
    end

    def employment_form_params
      params.expect(jobseekers_profile_employment_form: [*employment_attrs])
            .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
    end

    def employment_attrs
      %i[organisation job_title started_on is_current_role ended_on main_duties subjects reason_for_leaving].freeze
    end
  end
end
