# frozen_string_literal: true

module Publishers
  module VacancyTemplates
    class VacancyTemplateStepProcess
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

      class << self
        def steps
          FORM_CLASSES.keys
        end

        def form_class(step)
          FORM_CLASSES.fetch(step)
        end

        def skip_step?(step, template)
          case step
          when :key_stages
            !template.allow_key_stages?
          when :subjects
            !template.allow_subjects?
          else
            false
          end
        end
      end
    end
  end
end
