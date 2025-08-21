# frozen_string_literal: true

module Publishers
  module Vacancies
    class ReferencesAndSelfDisclosureBaseController < JobApplications::BaseController
      include Wicked::Wizard

      FORMS = {
        collect_references: Publishers::JobApplication::CollectReferencesForm,
        ask_references_email: Publishers::JobApplication::ReferencesContactApplicantForm,
        collect_self_disclosure: Publishers::JobApplication::CollectSelfDisclosureForm,
      }.freeze

      private

      def form_class
        FORMS.fetch(step)
      end

      def form_for_update
        form_key = ActiveModel::Naming.param_key(form_class)
        form_class.new(params.fetch(form_key, {}).permit(form_class.fields))
      end
    end
  end
end
