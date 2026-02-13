# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class PreEmploymentChecksController < BaseController
        before_action :set_job_application

        def update
          pre_employment_check_set = @job_application.pre_employment_check_set || @job_application.build_pre_employment_check_set
          pre_employment_check_set.update!(pre_employment_params)
          redirect_to pre_employment_checks_organisation_job_job_application_path(@vacancy.id, @job_application.id), success: t(".success")
        end

        private

        def pre_employment_params
          params.expect(pre_employment_check_set: %i[identity_check
                                                     enhanced_dbs_check
                                                     overseas_checks
                                                     right_to_work_in_uk
                                                     professional_qualifications
                                                     childrens_barred_list
                                                     mental_and_physical_fitness])
        end
      end
    end
  end
end
