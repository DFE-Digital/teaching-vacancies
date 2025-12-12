# frozen_string_literal: true

module Referees
  class BuildReferencesController < ApplicationController
    include Wicked::Wizard

    before_action :set_reference, only: %i[show update]
    before_action :check_application_status, only: %i[show update]

    FORMS = {
      can_give: Referees::CanGiveReferenceForm,
      can_share: Referees::CanShareReferenceForm,
      fit_and_proper_persons: Referees::FitAndProperPersonsForm,
      employment_reference: Referees::EmploymentReferenceForm,
      reference_information: Referees::ReferenceInformationForm,
      how_would_you_rate_part_1: Referees::HowWouldYouRateForm1,
      how_would_you_rate_part_2: Referees::HowWouldYouRateForm2,
      how_would_you_rate_part_3: Referees::HowWouldYouRateForm3,
      referee_details: Referees::RefereeDetailsForm,
    }.freeze

    steps(*FORMS.keys)

    def show
      if step != Wicked::FINISH_STEP
        if @reference.can_give_reference == false
          jump_to Wicked::FINISH_STEP
        else
          @form = if step == :referee_details
                    form_class.new(token: token,
                                   name: @referee.name,
                                   job_title: @referee.job_title,
                                   email: @referee.email,
                                   organisation: @referee.organisation,
                                   phone_number: @referee.phone_number)
                  else
                    # This allows the 'back' button to pick up previously entered data.
                    form_class.new(@reference.slice(*form_class.fields).merge(token: token))
                  end
        end
      end
      render_wizard(nil, {}, token: token)
    end

    def update
      @form = form_class.new(params.expect(form_key => [*(form_class.fields + [:token])]))
      if @form.valid?
        @reference.update!(@form.params_to_save)
        # invalidate token after reference is complete
        if @reference.complete?
          @reference.mark_as_received
          next_token = @reference_request.token
        else
          next_token = token
        end
        redirect_to next_wizard_path(token: next_token)
      else
        render step
      end
    end

    def completed; end
    def no_reference; end

    private

    def form_class
      FORMS.fetch(step)
    end

    def form_key
      ActiveModel::Naming.param_key(form_class)
    end

    def token
      params[:token] || params.expect(form_key => [:token]).fetch(:token)
    end

    def set_reference
      @reference_request = ReferenceRequest.active_token(token)
                                           .find(params[:reference_id])
      @reference = @reference_request.job_reference
      @referee = @reference_request.referee
    end

    def check_application_status
      if @reference_request.referee.job_application.status.in?(JobApplication::TERMINAL_STATUSES)
        render :no_longer_available and return
      end
    end

    def finish_wizard_path
      if @reference.can_give_reference?
        completed_reference_build_index_path(@reference_request.id)
      else
        no_reference_reference_build_index_path(@reference_request.id)
      end
    end
  end
end
