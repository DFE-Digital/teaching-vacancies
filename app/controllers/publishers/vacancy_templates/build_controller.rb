# frozen_string_literal: true

module Publishers
  module VacancyTemplates
    class BuildController < Publishers::BaseController
      include Wicked::Wizard
      include Publishers::Wizardable

      before_action :load_template

      FORM_CLASSES = {
        job_role: JobListing::JobRoleForm,
        education_phases: JobListing::EducationPhasesForm,
        key_stages: JobListing::KeyStagesForm,
        subjects: JobListing::SubjectsForm,
        contract_information: JobListing::ContractInformationForm,
        pay_package: JobListing::PayPackageForm,
        about_the_role: JobListing::AboutTheRoleForm,
        school_visits: JobListing::SchoolVisitsForm,
        visa_sponsorship: JobListing::VisaSponsorshipForm,
        applying_for_the_job: JobListing::ApplyingForTheJobForm,
        how_to_receive_applications: JobListing::HowToReceiveApplicationsForm,
        anonymise_applications: JobListing::AnonymiseApplicationsForm,
      }.freeze

      steps(*FORM_CLASSES.keys)

      def show
        if step == :key_stages && !@template.allow_key_stages?
          skip_step
        elsif step != Wicked::FINISH_STEP
          @form = form_class.load_from_model(@template, current_publisher: current_publisher)
        end

        render_wizard
      end

      def update
        @form = form_class.load_from_params(form_params, @template, current_publisher: current_publisher)

        if @form.valid?
          @template.update!(@form.params_to_save)
          redirect_to next_wizard_path
        else
          render_wizard
        end
      end

      private

      def finish_wizard_path
        organisation_vacancy_templates_path
      end

      def form_class
        FORM_CLASSES.fetch(step)
      end

      def load_template
        @template = VacancyTemplate.find(params[:vacancy_template_id])
      end
    end
  end
end
