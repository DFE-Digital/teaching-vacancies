require 'multistep/controller'

module Jobseekers::Profiles
  class JobPreferencesController < ApplicationController
    include Multistep::Controller

    multistep_form Jobseekers::JobPreferencesForm, key: :job_preferences
    escape_path { jobseekers_profile_path }

    on_completed(:locations) do |form|
      redirect_to action: :edit_location if form.add_location
      form.add_location = nil
    end

    before_action :force_location_added, if: -> { current_step == :locations }

    def start
      redirect_to action: :edit, step: all_steps.first
    end

    def edit_location
      @current_step = :locations
      @escape_path = { action: :edit, step: :locations } if form.locations.any?

      redirect_to action: :edit, step: :locations and return unless location_form
      render 'location'
    end

    def update_location
      location_form.assign_attributes(params.require(:job_preferences_location).to_unsafe_hash)
      if location_form.valid?
        form.update_location(location_id, location_form.attributes)
        form.complete_step!(:locations)
        store_form!
        redirect_to action: :edit, step: :locations
      else
        @current_step = :locations
        @escape_path = { action: :edit, step: :locations } if form.locations.any?

        render 'location', status: :unprocessable_entity
      end
    end

    def delete_location

    end

    def review
    end

    private

    # def complete
    #   # redirect_to action: :review
    # end

    def store_form!
      job_preference_record.update!(form.attributes.without('add_location'))
    end

    def attributes_from_store
      job_preference_record.attributes.slice(*self.class.multistep_form.attribute_names)
    end

    def job_preference_record
      @job_preference_record ||= JobPreferences.find_or_create_by(jobseeker_id: current_jobseeker.id)
    end

    def force_location_added
      redirect_to action: :edit_location if form.locations.empty?
    end

    def location_id
      return @location_id if defined? @location_id

      @location_id = params[:id].to_i - 1 if params[:id]
    end

    helper_method def location_form
      @location_form ||= form.build_location_form(location_id)
    end
  end
end
