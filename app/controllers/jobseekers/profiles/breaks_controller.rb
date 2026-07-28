module Jobseekers
  class Profiles::BreaksController < ProfilesController
    before_action :set_employment_break, only: %i[update edit destroy]

    def new
      form_attributes = if params[:started_on] && params[:ended_on]
                          { started_on: Date.parse(params[:started_on]), ended_on: Date.parse(params[:ended_on]) }
                        else
                          # simplecov:disable
                          {}
                          # simplecov:enable
                        end
      @employment_break = @profile.employment_gaps.build(form_attributes)
    end

    def edit; end

    def create
      @employment_break = @profile.employment_gaps.build(employment_break_params)
      if @employment_break.save
        redirect_to back_path
      else
        render :new
      end
    end

    def update
      if @employment_break.update(employment_break_params)
        redirect_to back_path
      else
        render :edit
      end
    end

    def confirm_destroy
      @employment_break = @profile.employment_gaps.find(params[:break_id])
    end

    def destroy
      @employment_break.destroy
      redirect_to back_path
    end

    private

    def back_path
      jobseekers_profile_path
    end

    def set_employment_break
      @employment_break = @profile.employment_gaps.find(params[:id])
    end

    def employment_break_params
      params.expect(jobseekers_break_form: %i[reason_for_break started_on ended_on])
            .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
    end
  end
end
