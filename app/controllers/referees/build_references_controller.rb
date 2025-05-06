# frozen_string_literal: true

module Referees
  class BuildReferencesController < ApplicationController
    include Wicked::Wizard

    before_action :set_reference, only: %i[show update]

    FORMS = {
      can_give: Referees::CanGiveReferenceForm,
      can_share: Referees::CanShareReferenceForm,
      fit_and_proper_persons: Referees::FitAndProperPersonsForm,
      employment_reference: Referees::EmploymentReferenceForm,
      reference_information: Referees::ReferenceInformationForm,
      how_would_you_rate: Referees::HowWouldYouRateForm,
      referee_details: Referees::RefereeDetailsForm,
    }.freeze

    steps(*FORMS.keys)
    def show
      if step.to_sym != :wicked_finish
        if @reference.can_give_reference?
          @form = FORMS.fetch(step).new(token: token)
        else
          jump_to :wicked_finish
        end
      end
      render_wizard(nil, {}, token: token)
    end

    def update
      @form = form_class.new(params.require(form_key)
                                   .permit(*(form_class.storable_fields + [:token])))
      if @form.valid?
        @reference.update!(@form.params_to_save)
        redirect_to next_wizard_path(token: token)
      else
        render step
      end
    end

    def completed; end

    private

    def form_class
      FORMS.fetch(step)
    end

    def form_key
      form_class.to_s.underscore.tr("/", "_")
    end

    def token
      params[:token] || params.require(form_key).permit(:token).fetch(:token)
    end

    def set_reference
      @reference = JobReference.where(token: token).find(params[:reference_id])
    end

    def finish_wizard_path
      completed_reference_build_index_path(@reference.id)
    end
  end
end
