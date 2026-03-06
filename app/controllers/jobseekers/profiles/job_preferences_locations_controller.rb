# frozen_string_literal: true

module Jobseekers
  module Profiles
    class JobPreferencesLocationsController < Jobseekers::BaseController
      helper_method :escape_path

      before_action :load_location, only: %i[edit update delete_location]

      def index
        @form = LocationsForm.new(locations: model.locations)
      end

      def new
        @location = model.locations.build
      end

      def edit; end

      def create
        @location = model.locations.build(location_params)

        if @location.save
          model.update!(completed_steps: model.completed_steps.merge(locations: :completed))
          redirect_to jobseekers_job_preferences_locations_path
        else
          render "new"
        end
      end

      def update
        if @location.update(location_params)
          redirect_to jobseekers_job_preferences_locations_path
        else
          render "edit", status: :unprocessable_entity
        end
      end

      def add_new
        @form = LocationsForm.new(add_new_params)
        if @form.valid?
          if @form.add_location
            redirect_to new_jobseekers_job_preferences_location_path
          else
            redirect_to review_jobseekers_job_preferences_steps_path
          end
        else
          render "index"
        end
      end

      def delete_location
        @profile = current_jobseeker.jobseeker_profile
        @last_location = model.locations.one?
        @delete_form = DeleteLocationForm.new
      end

      def destroy
        @profile = current_jobseeker.jobseeker_profile
        ApplicationRecord.transaction do
          model.locations.delete params[:id]
          # :nocov:
          if model.locations.empty?
            model.update!(completed_steps: model.completed_steps.merge(locations: :invalidated))
            @profile.deactivate!
          end
          # :nocov:
        end
        flash[:success] = "Location deleted"
        redirect_to new_jobseekers_job_preferences_location_path
      end

      private

      def load_location
        @location = model.locations.find(params[:id])
      end

      def add_new_params
        params.expect(jobseekers_profiles_locations_form: %i[add_location])
      end

      def location_params
        params.expect(job_preferences_location: %i[name radius])
      end

      def model
        current_jobseeker.jobseeker_profile.job_preferences
      end

      def escape_path
        jobseekers_profile_path
      end
    end
  end
end
