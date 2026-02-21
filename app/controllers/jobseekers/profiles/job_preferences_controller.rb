require "multistep/controller"

module Jobseekers::Profiles
  class JobPreferencesController < Jobseekers::BaseController
    include Wicked::Wizard

    FORMS = {
      roles: RolesForm,
      phases: PhasesForm,
      key_stages: KeyStagesForm,
      subjects: SubjectsForm,
      working_patterns: WorkingPatternsForm,
      locations: LocationsForm,
    }.freeze

    steps :roles, :phases, :key_stages, :subjects, :working_patterns, :locations

    helper_method :escape_path

    before_action :set_model, only: %i[show update]

    def show
      @form = form_class.new
      skip_step if @form.skip?(@model)
      render_wizard
    end

    def update
      @form = form_class.new(params.expect(form_key => form_class.fields))
      if @form.valid?
        @model.update!(@form.params_to_save)
        redirect_to next_wizard_path
      else
        render step
      end
    end

    # include Multistep::Controller
    #
    # multistep_form Jobseekers::JobPreferencesForm, key: :job_preferences
    # escape_path { jobseekers_profile_path }
    def escape_path
      jobseekers_profile_path
    end
    #
    # on_completed(:locations) do |form|
    #   redirect_to action: :edit_location if form.add_location
    #   form.add_location = nil
    # end
    #
    # before_action :force_location_added, if: -> { current_step == :locations }
    #
    # def start
    #   redirect_to action: :edit, step: all_steps.first
    # end

    def edit_location
      setup_location_view
      redirect_to action: :edit, step: :locations and return unless location_form

      render "location"
    end

    def update_location
      location_form.assign_attributes(params.require(:job_preferences_location).to_unsafe_hash)
      if location_form.valid?
        form.update_location(params[:id], location_form.attributes)
        form.complete_step!(:locations)
        store_form!
        redirect_to action: :edit, step: :locations
      else
        setup_location_view
        render "location", status: :unprocessable_entity
      end
    end

    def delete_location
      setup_location_view
      @location = form.locations[params[:id]]
      @last_location = form.locations.one?
      @delete_form = Jobseekers::JobPreferencesForm::DeleteLocationForm.new
    end

    def process_delete_location
      delete_location
      @delete_form.assign_attributes(params.require(:delete_location).to_unsafe_hash)
      render "delete_location", status: :unprocessable_entity and return unless form.valid?

      if @delete_form.action == "delete"
        form.locations.delete params[:id]
        ApplicationRecord.transaction do
          if form.locations.empty?
            form.complete_step!(:locations, :invalidated)
            @profile.deactivate!
          end
          store_form!
        end
        flash[:success] = "Location deleted"
        redirect_to escape_path
      else
        redirect_to action: :edit_location, id: params[:id]
      end
    end

    def review; end

    private

    def form_class
      FORMS.fetch(step)
    end

    def form_key
      ActiveModel::Naming.param_key(form_class)
    end

    def set_model
      @model = current_jobseeker.jobseeker_profile.job_preferences || current_jobseeker.jobseeker_profile.build_job_preferences
    end

    def setup_location_view
      @escape_path = @back_url = { action: :edit, step: :locations } if form.locations.any?
      @current_step = :locations
    end

    def complete
      redirect_to action: :review
    end

    def store_form!
      ApplicationRecord.transaction do
        job_preference_record.update!(form.attributes.without("add_location", "locations"))
        job_preference_record.locations.where.not(id: form.locations.keys).destroy_all
        form.locations.each do |id, attrs|
          loc = job_preference_record.locations.find_or_initialize_by(id: id)
          loc.assign_attributes(name: attrs[:location], radius: attrs[:radius])
          loc.save!
        end
      end
    end

    def form
      @form ||= self.class.multistep_form.from_record(job_preference_record)
    end

    def job_preference_record
      @job_preference_record ||= @profile.job_preferences || @profile.build_job_preferences
    end

    def force_location_added
      redirect_to action: :edit_location if form.locations.empty?
    end

    helper_method def location_form
      @location_form ||= form.build_location_form(params[:id])
    end
  end
end
